module SocialStream
  module Oauth2Server
    module Controllers
      # Common methods added to ApplicationController
      module Helpers
        extend ActiveSupport::Concern

        def current_subject
          super ||
            @current_subject ||=
              current_from_oauth_token(:client)
        end

        def current_user
          super ||
            @current_user ||=
              current_from_oauth_token(:user)
        end

        def current_from_oauth_token(type)
          return if oauth2_token.blank?

          oauth2_token.__send__(type)
        end

        def oauth2_token
          @oauth2_token ||=
            request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
        end
      end
    end
  end
end
