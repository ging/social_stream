# Owner of client sites
class Relation::Manager < Relation::Single
  PERMISSIONS =
    [
      [ 'manage', nil ],
      [ 'manage', 'relation/custom' ],
      [ 'manage', 'contact' ]
    ]

  class << self
    def create_activity?
      false
    end
  end

  def available_permissions
    Permission.instances PERMISSIONS
  end
end
