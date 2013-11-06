# This role is the administrator of current site
#
class Relation::LocalAdmin < Relation::Single
  PERMISSIONS = SocialStream.available_permissions['site/current']

  class << self
    def create_activity?
      false
    end
  end
end
