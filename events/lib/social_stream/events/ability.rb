module SocialStream
  module Events
    module Ability
      def initialize(subject)
        super

        can [:create, :destroy], Room do |r|
          r.actor_id == Actor.normalize_id(subject)
        end
      end
    end
  end
end
