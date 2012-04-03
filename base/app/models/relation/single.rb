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
      self::PERMISSIONS.map{ |p|
        Permission.find_or_create_by_action_and_object p.first, p.last
      }
    end

  end

  # The name of public relation
  def name
    I18n.t("relation_#{ self.class.name.split("::").last.underscore }.name")
  end
end
