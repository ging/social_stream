module SocialStream
  module Oauth2Server
    module Controllers
      # Common methods added to ApplicationController
      module Helpers
        extend ActiveSupport::Concern

        def current_subject
          super ||
            @current_subject ||=
              current_subject_from_oauth_token
        end

        def current_subject_from_oauth_token
          return if oauth2_token.blank?

          oauth2_token.user.present? ?
            oauth2_token.user :
            oauth2_token.client
        end

        def oauth2_token
          @oauth2_token ||=
            Oauth2Token::AccessToken.valid.find_by_token request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
        end

      end
    end
  end
end
