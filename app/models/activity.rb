class Activity < ActiveRecord::Base

  belongs_to :parent,
             :class_name => "Activity",
             :foreign_key => :parent_id

  has_many :children,
           :class_name => "Activity",
           :foreign_key => :parent_id

  belongs_to :activity_verb
  has_many :activity_object_activities
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
    liked_by(user).any?
  end

  class << self
    def wall(ties_query)
      select( "DISTINCT activities.*").
        where("activities.parent_id" => nil).
        where("activities.tie_id IN (#{ ties_query })").
        order("created_at desc")
    end
  end
end
