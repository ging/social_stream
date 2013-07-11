# Owner of client sites
class Relation::Manager < Relation::Single
  PERMISSIONS = SocialStream.available_permissions['site/client']

  class << self
    def create_activity?
      false
    end
  end
end
