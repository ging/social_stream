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

      initializer "social_stream-events.views.settings" do
        SocialStream::Views::Settings.module_eval do
          include SocialStream::Views::Settings::Events
        end
      end

      initializer "social_stream-events.views.sidebar" do
        SocialStream::Views::Sidebar.module_eval do
          include SocialStream::Views::Sidebar::Events
        end
      end
    end
  end
end
