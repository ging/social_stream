# Authorize a {Site::Client} to access data
class Relation::Auth < Relation::Single
  class << self
    def create_activity?
      false
    end
  end
end
