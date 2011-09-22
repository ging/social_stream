module SocialStream
  module Events
    class Engine < Rails::Engine
      initializer "social_stream-events.toolbar_config" do
        SocialStream::ToolbarConfig.module_eval do
          include SocialStream::ToolbarConfig::Events
        end
      end
    end
  end
end
