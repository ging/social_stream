module SocialStream
  module Events
    class Engine < Rails::Engine
      initializer "social_stream-events.ability" do
        SocialStream::Ability.module_eval do
          include SocialStream::Events::Ability
        end
      end

      initializer "social_stream-events.models.register_activity_streams" do
        SocialStream::ActivityStreams.register :event
      end
    end
  end
end
