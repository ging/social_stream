class ActivityVerb < ActiveRecord::Base
  # Activity Strems verbs
  Available = %w(start_following like make_friend update post)

  validates_uniqueness_of :name

  has_many :activities

  scope :verb_name, lambda{ |n|
    where(:name => n)
  }

  class << self
    def [] name
      if Available.include?(name)
        find_or_create_by_name name
      else
        raise "ActivityVerb not available: #{ name }"
      end
    end
  end
end
