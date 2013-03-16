# Activities follow the {Activity Streams}[http://activitystrea.ms/] standard.
#
# Every {Activity} has an {#author}, {#user_author} and {#owner}
#
# author:: Is the {SocialStream::Models::Subject subject} that originated
#          the activity. The entity that posted something, liked, etc..
#
# user_author:: The {User} logged in when the {Activity} was created.
#               If the {User} has not changed the session to represent
#               other entity (a {Group} for example), the user_author
#               will be the same as the author.
#
# owner:: The {SocialStream::Models::Subject subject} whose wall was posted
#         or comment was liked, etc..
#
# == {Audience Audiences} and visibility
# Each activity is attached to one or more {Relation relations}, which define
# the {SocialStream::Models::Subject subject} that can reach the activity
#
# In the case of a {Relation::Public public relation} everyone will be
# able to see the activity.
#
# In the case of {Relation::Custom custom relations}, only the subjects
# that have a {Tie} with that relation (in other words, the contacts that
# have been added as friends with that relation} will be able to reach the {Activity}
#
class Activity < ActiveRecord::Base
  # FIXME: this does not follow the Rails way
  include NotificationsHelper

  # This has to be declared before 'has_ancestry' to work around rails issue #670
  # See: https://github.com/rails/rails/issues/670
  before_destroy :destroy_children_comments
  before_destroy :decrement_like_count, :delete_notifications

  has_ancestry

  paginates_per 10

  belongs_to :activity_verb

  belongs_to :author,
             :class_name => "Actor"
  belongs_to :owner,
             :class_name => "Actor"
  belongs_to :user_author,
             :class_name => "Actor"

  has_many :audiences, :dependent => :destroy
  has_many :relations, :through => :audiences

  has_many :activity_object_activities,
           :dependent => :destroy
  has_many :activity_objects,
           :through => :activity_object_activities

  scope :authored_by, lambda { |subject|
    where(:author_id => Actor.normalize_id(subject))
  }
  scope :owned_by, lambda { |subject|
    where(:owner_id => Actor.normalize_id(subject))
  }
  scope :authored_or_owned_by, lambda { |subjects|
    if subjects.present?
      ids = Actor.normalize_id(subjects)

      where(arel_table[:author_id].in(ids).or(arel_table[:owner_id].in(ids)))
    end
  }

  scope :shared_with, lambda { |subject|
    joins(:audiences).
      merge(Audience.where(:relation_id => Relation.ids_shared_with(subject)))
  }

  scope :timeline, lambda { |senders = nil, receivers = nil|
    if senders == :home
      senders = receivers.following_actor_and_self_ids
    end

    select("DISTINCT activities.*").
      roots.
      includes(:author, :user_author, :owner, :activity_objects, :activity_verb, :relations).
      authored_or_owned_by(senders).
      shared_with(receivers).
      order("created_at desc")
  }


  after_create  :increment_like_count

  validates_presence_of :author_id, :user_author_id, :owner_id, :relations
 
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

  # The {SocialStream::Models::Subject subject} author
  def author_subject
    author.subject
  end

  # The {SocialStream::Models::Subject subject} owner
  def owner_subject
    owner.subject
  end

  # The {SocialStream::Models::Subject subject} user actor
  def user_author_subject
    user_author.subject
  end

  # Does this {Activity} have the same sender and receiver?
  def reflexive?
    author_id == owner_id
  end

  # Is the author represented in this {Activity}?
  def represented_author?
    author_id != user_author_id
  end

  # The {Actor} author of this activity
  #
  # This method provides the {Actor}. Use {#sender_subject} for the {SocialStream::Models::Subject Subject}
  # ({User}, {Group}, etc..)
  def sender
    author
  end

  # The {SocialStream::Models::Subject Subject} author of this activity
  #
  # This method provides the {SocialStream::Models::Subject Subject} ({User}, {Group}, etc...).
  # Use {#sender} for the {Actor}.
  def sender_subject
    author_subject
  end

  # The wall where the activity is shown belongs to receiver
  #
  # This method provides the {Actor}. Use {#receiver_subject} for the {SocialStream::Models::Subject Subject}
  # ({User}, {Group}, etc..)
  def receiver
    owner
  end

  # The wall where the activity is shown belongs to the receiver
  #
  # This method provides the {SocialStream::Models::Subject Subject} ({User}, {Group}, etc...).
  # Use {#receiver} for the {Actor}.
  def receiver_subject
    owner_subject
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
    likes.authored_by(user)
  end

  # Does user like this activity?
  def liked_by?(user)
    liked_by(user).present?
  end

  # Build a new children activity where subject like this
  def new_like(subject, user)
    a = children.new :verb           => "like",
                     :author_id      => Actor.normalize_id(subject),
                     :user_author_id => Actor.normalize_id(user),
                     :owner_id       => owner_id,
                     :relation_ids   => self.relation_ids

    if direct_activity_object.present?
      a.activity_objects << direct_activity_object
    end

    a
  end

  # The first activity object of this activity
  def direct_activity_object
    @direct_activity_object ||=
      activity_objects.first
  end

  # The first object of this activity
  def direct_object
    @direct_object ||=
      direct_activity_object.try(:object)
  end

  # The title for this activity in the stream
  def title view
    case verb
    when "follow", "make-friend", "like"
      I18n.t "activity.verb.#{ verb }.#{ receiver.subject_type }.title",
      :subject => view.link_name(sender_subject),
      :contact => view.link_name(receiver_subject)
    when "post", "update"
      if sender == receiver
        view.link_name sender_subject
      else
        I18n.t "activity.verb.post.title.other_wall",
               :sender => view.link_name(sender_subject),
               :receiver => view.link_name(receiver_subject)
      end
    when 'join'
      I18n.t('notification.join.one', 
            :sender => view.link_name(sender_subject),
            :thing => I18n.t(direct_object.class.to_s.underscore+'.one'),
            :title => title_of(direct_object))
    else
      "Must define activity title"
    end.html_safe
  end

  # Title for activity streams
  def stream_title
    # FIXMEEEEEEEEEEEEEEEEE
    object = ( direct_object.present? ? 
               ( direct_object.is_a?(SocialStream::Models::Subject) ? 
                 direct_object.name :
                 direct_object.title ) :
               receiver.name )

    I18n.t "activity.stream.title.#{ verb }",
           :author => sender_subject.name,
           :activity_object => object
  end

  # TODO: detailed description of activity
  def stream_content
    stream_title
  end
  
  def notificable?
    is_root? or ['post','update'].include?(root.verb)
  end

  def notify
    return true unless notificable?
    #Avaible verbs: follow, like, make-friend, post, update, join

    if direct_object.is_a? Comment
      participants.each do |p|
        p.notify(notification_subject, "Youre not supposed to see this", self) unless p == sender
      end
    elsif ['like','follow','make-friend','post','update', 'join'].include? verb and !reflexive?
      receiver.notify(notification_subject, "Youre not supposed to see this", self)
    end
    true
  end

  # A list of participants
  def participants
    parts=Set.new
    same_thread.map{|a| a.activity_objects.first}.each do |ao|
      parts << ao.author if ao.respond_to? :author and !ao.author.nil?
    end
    parts
  end

  # This and related activities
  def same_thread
    return [self] if is_root?
    [parent] + siblings
  end

  # Is this activity public?
  def public?
    relation_ids.include? Relation::Public.instance.id
  end

  # The {Actor Actors} this activity is shared with
  def audience
    raise "Cannot get the audience of a public activity!" if public?

    [ author, user_author, owner ].uniq |
      Actor.
        joins(:received_ties).
        merge(Tie.where(:relation_id => relation_ids))
  end

  # The {Relation} with which activity is shared
  def audience_in_words(subject, options = {})
    options[:details] ||= :full

    public_relation = relations.select{ |r| r.is_a?(Relation::Public) }

    visibility, audience =
      if public_relation.present?
        [ :public, nil ]
      else
        visible_relations =
          relations.select{ |r| r.actor_id == Actor.normalize_id(subject)}

        if visible_relations.present?
          [ :visible, visible_relations.map(&:name).uniq.join(", ") ]
        else
          [ :hidden, relations.map(&:actor).map(&:name).uniq.join(", ") ]
        end
      end

    I18n.t "activity.audience.#{ visibility }.#{ options[:details] }", :audience => audience
  end

  private

  #
  # Get the email subject for the activity's notification
  #
  def notification_subject
    sender_name= sender.name.truncate(30, :separator => ' ')
    receiver_name= receiver.name.truncate(30, :separator => ' ')
    case verb 
      when 'like'
        if direct_object.acts_as_actor?
          I18n.t('notification.fan', 
                :sender => sender_name,
                :whose => I18n.t('notification.whose.'+ receiver.subject.class.to_s.underscore,
                            :receiver => receiver_name))
        else
          I18n.t('notification.like.'+ receiver.subject.class.to_s.underscore, 
                :sender => sender_name,
                :whose => I18n.t('notification.whose.'+ receiver.subject.class.to_s.underscore,
                            :receiver => receiver_name),
                :thing => I18n.t(direct_object.class.to_s.underscore+'.name'))
        end
      when 'follow'
        I18n.t('notification.follow.'+ receiver.subject.class.to_s.underscore, 
              :sender => sender_name,
              :who => I18n.t('notification.who.'+ receiver.subject.class.to_s.underscore,
                             :name => receiver_name))
      when 'make-friend'
        I18n.t('notification.makefriend.'+ receiver.subject.class.to_s.underscore, 
              :sender => sender_name,
              :who => I18n.t('notification.who.'+ receiver.subject.class.to_s.underscore,
                              :name => receiver_name))
      when 'post'
        I18n.t('notification.post.'+ receiver.subject.class.to_s.underscore, 
            :sender => sender_name,
            :whose => I18n.t('notification.whose.'+ receiver.subject.class.to_s.underscore,
                              :receiver => receiver_name),
	    :title => title_of(direct_object))
      when 'update'
        I18n.t('notification.update.'+ receiver.subject.class.to_s.underscore, 
              :sender => sender_name,
              :whose => I18n.t('notification.whose.'+ receiver.subject.class.to_s.underscore,
                               :receiver => receiver_name),
              :thing => I18n.t(direct_object.class.to_s.underscore+'.one'))
      when 'join'
        I18n.t('notification.join.one'  , 
            :sender => sender_name,
            :thing => I18n.t(direct_object.class.to_s.underscore+'.title.one'),
            :title => title_of(direct_object))
      
      else
        t('notification.default')
      end
  end
  
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

  # before_destroy callback
  #
  # Destroy children comments when the activity is destroyed
  def destroy_children_comments
    comments.each do |c|
      c.direct_object.destroy
    end
  end

  # after_destroy callback
  #
  # Decrement like counter in objects when like activity is destroyed
  def decrement_like_count
    return if verb != "like" || direct_activity_object.blank?

    direct_activity_object.decrement!(:like_count)
  end
  
  # after_destroy callback
  #
  # Destroy any Notification linked with the activity
  def delete_notifications
    Notification.with_object(self).each do |notification|
      notification.destroy
    end
  end
end
