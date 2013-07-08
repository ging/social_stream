# Owner of {Group groups}
class Relation::Owner < Relation::Single
  PERMISSIONS = SocialStream.available_permissions['group']

  class << self
    def create_activity?
      false
    end
  end
end
