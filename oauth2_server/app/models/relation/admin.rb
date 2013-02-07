# Administer client sites
class Relation::Admin < Relation::Single
  class << self
    def create_activity?
      false
    end
  end
end

