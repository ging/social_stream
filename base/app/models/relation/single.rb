# Common methods for single relations, like {Relation::Public} and {Relation::Reject}
#
# Unlike {Relation::Custom}, {SocialStream::Models::Subject subjects} have only one of
# these {Relation relations}.
#
class Relation::Single < Relation
  PERMISSIONS = []

  class << self
    def instance
      @instance ||=
        first ||
          create!(:permissions => permissions)
    end

    def permissions
      Permission.instances self::PERMISSIONS
    end
  end

  # The name of public relation
  def name
    I18n.t("relation_#{ self.class.name.split("::").last.underscore }.name")
  end

  # The available permissions for {Relation::Single} match with the permissions
  # described in the variable
  def available_permissions
    self.class.permissions
  end
end
