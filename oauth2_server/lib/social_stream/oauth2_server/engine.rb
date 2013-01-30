module SocialStream
  module Oauth2Server
    class Engine < Rails::Engine
      initializer "social_stream-oauth2_server.controller.helpers",
                  after: "social_stream-base.controller.helpers" do
        ActiveSupport.on_load(:action_controller) do
          include SocialStream::Oauth2Server::Controllers::Helpers
        end
      end
    end
  end
end
