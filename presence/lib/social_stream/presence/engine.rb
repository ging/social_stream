module SocialStream
  module Presence
    class Engine < Rails::Engine
      initializer "social_stream-presence.tie" do
        ActiveSupport.on_load(:tie) do
          include SocialStream::Presence::Models::BuddyManager
        end
      end
    end
  end
end
