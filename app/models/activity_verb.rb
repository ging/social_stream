class ActivityVerb < ActiveRecord::Base
  # Activity Strems verbs
  Available = %w( post update like )

  validates_uniqueness_of :name

  has_many :activities

  scope :verb_name, lambda{ |n|
    where(:name => n)
  }

  class << self
    def [] name
      verb_name(name).first
    end
  end
end
