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

  has_one :author,
          :through => :tie,
          :source => :sender
  has_one :wall,
          :through => :tie,
          :source => :receiver
  has_one :relation,
          :through => :tie

  def verb
    activity_verb.name
  end

  def verb=(name)
    self.activity_verb = ActivityVerb[name]
  end

  def comments
    children.includes(:activity_objects).where('activity_objects.object_type' => "Comment")
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
