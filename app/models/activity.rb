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

  after_create :like_direct_object

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

  # After an activity is created, it is associated to ties
  attr_accessor :_tie
  after_create :assign_to_ties

  # The name of the verb of this activity
  def verb
    activity_verb.name
  end

  # Set the name of the verb of this activity
  def verb=(name)
    self.activity_verb = ActivityVerb[name]
  end

  # The author of the activity is the receiver of the tie
  #
  # This method provides the actor. Use sender_subject for the subject (user, group, etc..)
  def sender
    tie.receiver
  end

  # The author of the activity is the receiver of the tie
  #
  # This method provides the subject (user, group, etc...). Use sender for the actor.
  def sender_subject
    tie.receiver_subject
  end

  # The wall where the activity is shown belongs to the sender of the tie
  #
  # This method provides the actor. Use sender_subject for the subject (user, group, etc..)
  def receiver
    tie.sender
  end

  # The wall where the activity is shown belongs to the sender of the tie
  #
  # This method provides the subject (user, group, etc...). Use sender for the actor.
  def receiver_subject
    tie.sender_subject
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
    likes.joins(:ties).where('tie_activities.original' => true).merge(Tie.received_by(user))
  end

  # Does user like this activity?
  def liked_by?(user)
    liked_by(user).present?
  end

  # Build a new children activity where subject like this
  def new_like(subject)
    children.new :verb => "like",
                 :_tie => subject.sent_ties(:receiver => receiver,
                                            :relation => relation).first
  end

  # The first activity object of this activity
  def direct_activity_object
    activity_objects.first
  end

  # The first object of this activity
  def direct_object
    direct_activity_object.try(:object)
  end

  private

  # Assign to ties of followers
  def assign_to_ties
    original = tie_activities.create!(:tie => _tie)

    # All the ties following the activities attached to this tie, allowed to read
    # this activity
    Tie.following([_tie.sender_id, _tie.receiver_id]).each do |t|
      if _tie.allows?(t.sender_id, 'read', 'activity')
        tie_activities.create!(:tie => t,
                               :original => false)
      end
    end
  end

  # Link like activities with parent direct object
  def like_direct_object
    return unless verb == "like"

    return if parent.direct_object.blank?

    activity_objects << parent.direct_activity_object
  end
end
