module SocialStream
  module Oauth2Server
    module Ability
      def initialize(subject)
        super

        can :read, Site::Client

        can :create, Site::Client do |c|
          subject.present? &&
            c.author_id == subject.actor_id
        end

        can [:update, :destroy], Site::Client do |c|
          c.allow? subject, 'manage'
        end

        can :read, Relation::Manager
      end
    end
  end
end

