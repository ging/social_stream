# Common methods for single relations, like {Relation::Public} and {Relation::Reject}
#
# Unlike {Relation::Custom}, {SocialStream::Models::Subject subjects} have only one of
# these {Relation relations}.
#
class Relation::Single < Relation
  class << self
    def default_for(actor)
      create! :actor => actor
    end

    # The {Relation::Public} belonging to actor
    def of(actor)
      actor(actor).first
    end
  end

  # The name of public relation
  def name
    I18n.t("relation_#{ self.class.name.split("::").last.underscore }.name")
  end
end
