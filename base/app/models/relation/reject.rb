class Relation::Reject < Relation::Single
  class << self
    def create_activity?
      false
    end
  end
end

