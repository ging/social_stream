# Activities follow the {Activity Streams}[http://activitystrea.ms/] standard.
#
# == Activities and Ties
# Every activity is attached to a Tie, which defines the sender, the receiver and
# the relation in which the activity is transferred
#
# == Wall
# The Activity.wall(ties) scope provides all the activities attached to a set of ties
#
class Activity < ActiveRecord::Base
  scope :wall, lambda { |ties|
    select("DISTINCT activities.*").
      roots.
      where(:tie_id => ties).
      order("created_at desc")
  }

  has_ancestry

  belongs_to :activity_verb
  has_many :activity_object_activities, :dependent => :destroy
  has_many :activity_objects, :through => :activity_object_activities

  belongs_to :tie,
             :include => [ :sender ]

  has_one :sender,
          :through => :tie
  has_one :receiver,
          :through => :tie
  has_one :relation,
          :through => :tie

  # The name of the verb of this activity
  def verb
    activity_verb.name
  end

  # Set the name of the verb of this activity
  def verb=(name)
    self.activity_verb = ActivityVerb[name]
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
    likes.includes(:tie) & Tie.sent_by(user)
  end

  # Does user like this activity?
  def liked_by?(user)
    liked_by(user).present?
  end

end
