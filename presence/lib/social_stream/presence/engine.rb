module SocialStream
  module Presence
    class Engine < Rails::Engine
      initializer "social_stream-presence.tie" do
        ActiveSupport.on_load(:tie) do
          include SocialStream::Presence::Models::BuddyManager
        end
      end

      initializer "social_stream-presence.views.settings" do
        SocialStream::Views::Settings.module_eval do
          include SocialStream::Views::Settings::Presence
        end
      end
    end
  end
end
