# Owner of client sites
class Relation::Owner < Relation::Single
  PERMISSIONS =
    [
      [ 'manage', nil ],
      [ 'manage', 'relation/custom' ]
    ]

  class << self
    def create_activity?
      false
    end
  end
end
