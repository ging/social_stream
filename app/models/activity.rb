# Activities follow the {Activity Streams}[http://activitystrea.ms/] standard.
#
# == Activities, Contacts and Audiences
# Every activity is attached to a {Contact}, which defines the sender and the receiver of the {Activity}
#
# Besides, the activity is attached to one or more relations, which define the audicence of the activity,
# the {actors Actor} that can reach it and their {permissions Permission}
#
# == Wall
# The Activity.wall(args) scope provides all the activities appearing in a wall
#
# There are two types of wall, :home and :profile. Check {Actor#wall} for more information
#
class Activity < ActiveRecord::Base
  has_ancestry

  belongs_to :contact
  belongs_to :activity_verb

  has_many :audiences, :dependent => :destroy
  has_many :relations, :through => :audiences

  has_many :activity_object_activities,
           :dependent => :destroy
  has_many :activity_objects,
           :through => :activity_object_activities

  scope :wall, lambda { |args|
    q =
      select("DISTINCT activities.*").
      joins(:contact).
      joins(:audiences).
      joins(:relations).
      roots

    if args[:object_type].present?
      q = q.joins(:activity_objects).
            where('activity_objects.object_type' => args[:object_type])
    end

    contacts   = Contact.arel_table
    audiences  = Audience.arel_table
    relations  = Relation.arel_table

    owner_conditions =
      contacts[:sender_id].eq(Actor.normalize_id(args[:owner])).
        or(contacts[:receiver_id].eq(Actor.normalize_id(args[:owner])))

    audience_conditions =
      audiences[:relation_id].eq(args[:relations]).
        or(relations[:type].eq('Relation::Public'))

    conds =
      case args[:type]
      when :home
        followed_conditions =
          contacts[:sender_id].in(args[:followed]).
            or(contacts[:receiver_id].in(args[:followed]))

        owner_conditions.
          or(followed_conditions.and(audience_conditions))
      when :profile
        if args[:for].present?
          visitor_conditions =
            contacts[:sender_id].eq(Actor.normalize_id(args[:for])).
              or(contacts[:receiver_id].eq(Actor.normalize_id(args[:for])))

          owner_conditions.
            and(visitor_conditions.or(audience_conditions))
        else
          owner_conditions.
            and(audience_conditions)
        end
      else
        raise "Unknown wall type: #{ args[:type] }" 
      end

    q.where(conds).
      order("created_at desc")
  }

  after_create  :increment_like_count
  after_destroy :decrement_like_count
 

  #For now, it should be the last one
  #FIXME
  after_create :send_notifications

  # The name of the verb of this activity
  def verb
    activity_verb.name
  end

  # Set the name of the verb of this activity
  def verb=(name)
    self.activity_verb = ActivityVerb[name]
  end

  # The {Actor} author of this activity
  #
  # This method provides the {Actor}. Use {#sender_subject} for the {SocialStream::Models::Subject Subject}
  # ({User}, {Group}, etc..)
  def sender
    contact.sender
  end

  # The {SocialStream::Models::Subject Subject} author of this activity
  #
  # This method provides the {SocialStream::Models::Subject Subject} ({User}, {Group}, etc...).
  # Use {#sender} for the {Actor}.
  def sender_subject
    contact.sender_subject
  end

  # The wall where the activity is shown belongs to receiver
  #
  # This method provides the {Actor}. Use {#receiver_subject} for the {SocialStream::Models::Subject Subject}
  # ({User}, {Group}, etc..)
  def receiver
    contact.receiver
  end

  # The wall where the activity is shown belongs to the receiver
  #
  # This method provides the {SocialStream::Models::Subject Subject} ({User}, {Group}, etc...).
  # Use {#receiver} for the {Actor}.
  def receiver_subject
    contact.receiver_subject
  end

  # The comments about this activity
  def comments
    children.includes(:activity_objects).where('activity_objects.object_type' => "Comment")
  end

  # The 'like' qualifications emmited to this activities
  def likes
    children.joins(:activity_verb).where('activity_verbs.name' => "like")
  end

  def liked_by(user) #:nodoc:
    likes.joins(:contact).merge(Contact.sent_by(user))
  end

  # Does user like this activity?
  def liked_by?(user)
    liked_by(user).present?
  end

  # Build a new children activity where subject like this
  def new_like(subject)
    a = children.new :verb => "like",
                     :contact => subject.contact_to!(receiver),
                     :relation_ids => subject.comment_relations(self).map(&:id)

    if direct_activity_object.present?
      a.activity_objects << direct_activity_object
    end

    a
  end

  # The first activity object of this activity
  def direct_activity_object
    activity_objects.first
  end

  # The first object of this activity
  def direct_object
    direct_activity_object.try(:object)
  end

  # The title for this activity in the stream
  def title view
    case verb
    when "follow", "make-friend", "like"
      I18n.t "activity.verb.#{ verb }.#{ receiver.subject_type }.title",
      :subject => view.link_name(sender_subject),
      :contact => view.link_name(receiver_subject)
    when "post"
      view.link_name sender_subject
    end.html_safe
  end

  def notificable?
    is_root? or ['post','update'].include?(root.verb)
  end

  def notify
    return true if !notificable?
    #Avaible verbs: follow, like, make-friend, post, update
    actionview = ActivitiesController.new.view_context

    if ['like','follow','make-friend','post','update'].include? verb and !contact.reflexive?
      notification_subject = actionview.render :partial => 'notifications/activities/' + verb + "_subject", :locals => {:activity => self}
      notification_body = actionview.render :partial =>  'notifications/activities/' + verb + "_body", :locals => {:activity => self}
      receiver.notify(notification_subject, notification_body, self)
    end
    true
  end

  # Is subject allowed to perform action on this {Activity}?
  def allow?(subject, action)
    return false if contact.blank?

    # We do not support private activities by now
    return false if relation_ids.blank?

    case action
    when 'create'
      return false if contact.sender_id != Actor.normalize_id(subject)

      rels = Relation.normalize(relation_ids)

      foreign_rels = rels.select{ |r| r.actor_id != contact.sender_id }

      # Only posting to own relations
      return true if foreign_rels.blank?

      return Relation.
               allow(subject, action, 'activity', :in => foreign_rels).all.size == foreign_rels.size
    when 'read'
      return true if [contact.sender_id, contact.receiver_id].include?(Actor.normalize_id(subject)) || relations.select{ |r| r.is_a?(Relation::Public) }.any?
    when 'update'
      return true if contact.sender_id == Actor.normalize_id(subject)
    when 'destroy'
      return true if [contact.sender_id, contact.receiver_id].include?(Actor.normalize_id(subject))
    end

    Relation.
      allow(subject, action, 'activity').
      where('relations.id' => relation_ids).
      any?
   end

  private

  #Send notifications to actors based on proximity, interest and permissions
  def send_notifications
    notify
  end

  # after_create callback
  #
  # Increment like counter in objects with a like activity
  def increment_like_count
    return if verb != "like" || direct_activity_object.blank?

    direct_activity_object.increment!(:like_count)
  end

  # after_destroy callback
  #
  # Decrement like counter in objects when like activity is destroyed
  def decrement_like_count
    return if verb != "like" || direct_activity_object.blank?

    direct_activity_object.decrement!(:like_count)
  end
end
