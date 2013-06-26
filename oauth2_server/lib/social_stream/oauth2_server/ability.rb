module SocialStream
  module Oauth2Server
    module Ability
      def initialize(subject)
        super

        can [:update, :destroy], Site::Client do |c|
          c.allow? subject, 'manage'
        end

        can :read, Relation::Manager
      end
    end
  end
end

