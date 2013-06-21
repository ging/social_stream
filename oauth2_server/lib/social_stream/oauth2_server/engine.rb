module SocialStream
  module Oauth2Server
    class Engine < Rails::Engine
      config.app_middleware.use Rack::OAuth2::Server::Resource::Bearer, 'Social Stream OAuth2' do |req|
        Oauth2Token::AccessToken.valid.find_by_token(req.access_token) || req.invalid_token!
      end

      initializer "social_stream-oauth2_server.ability" do
        SocialStream::Ability.module_eval do
          include SocialStream::Oauth2Server::Ability
        end
      end

      initializer "social_stream-oauth2_server.custom_relations" do
        SocialStream.custom_relations['site/client'] = {}
      end

      initializer "social_stream-oauth2_server.controller.helpers",
                  after: "social_stream-base.controller.helpers" do
        ActiveSupport.on_load(:action_controller) do
          include SocialStream::Oauth2Server::Controllers::Helpers
        end
      end

      initializer "social_stream-oauth2_server.add_filters" do |app|
        app.config.filter_parameters += [:secret]
        app.config.filter_parameters.uniq
      end
    end
  end
end
