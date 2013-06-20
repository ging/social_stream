# Owner of client sites
class Relation::Owner < Relation::Single
  PERMISSIONS =
    [
      [ 'update', nil ]
    ]

  class << self
    def create_activity?
      false
    end
  end
end
