# Activities follow the {Activity Streams}[http://activitystrea.ms/] standard.
#
# == Activities and Ties
# Every activity is attached to a Tie, which defines the sender, the receiver and
# the relation in which the activity is transferred
#
# == Wall
# The Activity.wall(type, ties) scope provides all the activities attached to a set of ties
# 
# There are two types of wall, :home and :profile. Check {Actor#wall} for more information
#
class Activity < ActiveRecord::Base
  has_ancestry

  belongs_to :activity_verb

  has_many :tie_activities, :dependent => :destroy
  has_many :ties, :through => :tie_activities

  has_one :tie,
          :through => :tie_activities,
          :conditions => { 'tie_activities.original' => true }

  delegate :relation, :to => :tie

  has_many :activity_object_activities,
           :dependent => :destroy
  has_many :activity_objects,
           :through => :activity_object_activities

  
  scope :wall, lambda { |type, ties|
    q = select("DISTINCT activities.*").
          roots.
          joins(:tie_activities).
          where('tie_activities.tie_id' => ties).
          order("created_at desc")

    # Profile wall is composed by original TieActivities. Not original are copies for followers
    if type == :profile
      q = q.where('tie_activities.original' => true)
    end

    q
  }

  after_create :send_notifications

  # After an activity is created, it is disseminated to follower ties
  attr_accessor :_tie
  after_create :disseminate_to_ties

  after_create  :increment_like_count
  after_destroy :decrement_like_count

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
    tie.sender 
  end

  # The {SocialStream::Models::Subject Subject} author of this activity
  #
  # This method provides the {SocialStream::Models::Subject Subject} ({User}, {Group}, etc...).
  # Use {#sender} for the {Actor}.
  def sender_subject
    tie.sender_subject
  end

  # The wall where the activity is shown belongs to receiver
  #
  # This method provides the {Actor}. Use {#receiver_subject} for the {SocialStream::Models::Subject Subject}
  # ({User}, {Group}, etc..)
  def receiver
    tie.receiver
  end

  # The wall where the activity is shown belongs to the receiver
  #
  # This method provides the {SocialStream::Models::Subject Subject} ({User}, {Group}, etc...).
  # Use {#receiver} for the {Actor}.
  def receiver_subject
    tie.receiver_subject
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
    likes.joins(:ties).where('tie_activities.original' => true).merge(Tie.sent_by(user))
  end

  # Does user like this activity?
  def liked_by?(user)
    liked_by(user).present?
  end

  # Build a new children activity where subject like this
  def new_like(subject)
    a = children.new :verb => "like",
                     :_tie => subject.sent_ties(:receiver => receiver).first

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
      I18n.t "activity.verb.#{ verb }.#{ tie.receiver.subject_type }.title",
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
    return nil if !notificable?
    #Avaible verbs: follow, like, make-friend, post, update        
    actionview = ActivitiesController.new.view_context    
    if ['like','follow','make-friend','post','update'].include? verb and _tie.sender!=_tie.receiver  
        notification_subject = actionview.render :partial => 'notifications/activities/' + verb + "_subject", :locals => {:activity => self}
        notification_body = actionview.render :partial =>  'notifications/activities/' + verb + "_body", :locals => {:activity => self}
    end 
    if notification_subject.present? and notification_body.present?
      receipts = _tie.receiver.notify(notification_subject, notification_body)
    end
  end

  private

  # Assign to ties of followers
  def disseminate_to_ties
    # Create the original sender tie_activity
    tie_activities.create!(:tie => _tie)
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

  # after_destroy callback
  #
  # Decrement like counter in objects when like activity is destroyed
  def decrement_like_count
    return if verb != "like" || direct_activity_object.blank?

    direct_activity_object.decrement!(:like_count)
  end
end
