class ActivityVerb < ActiveRecord::Base
  # Activity Strems verbs
  Available = %w( post update like )

  validates_uniqueness_of :name

  has_many :activities

  class << self
    def [] name
      find_by_name(name)
    end
  end
end
