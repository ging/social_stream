module SocialStream
  module Presence
    class Engine < Rails::Engine
      initializer "social_stream-presence.tie" do
        ActiveSupport.on_load(:tie) do
          include SocialStream::Presence::Models::BuddyManager
        end
      end
      
      initializer "social_stream-presence.group" do
        ActiveSupport.on_load(:group) do
          include SocialStream::Presence::Models::GroupManager
        end
      end

      initializer "social_stream-presence.views.settings" do
        SocialStream::Views::Settings.module_eval do
          include SocialStream::Views::Settings::Presence
        end
      end

      initializer "social_stream-presence.views.toolbar" do
        SocialStream::Views::Toolbar.module_eval do
          include SocialStream::Views::Toolbar::Presence
        end
      end
    end
  end
end
