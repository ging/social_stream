module SocialStream
  module Oauth2Server
    module Models
      module User
        extend ActiveSupport::Concern

        included do
          has_many :oauth2_tokens,
                   dependent: :destroy

          has_many :authorization_codes,
                   class_name: 'Oauth2Token::AuthorizationCode'

          has_many :access_tokens,
                   class_name: 'Oauth2Token::AccessToken'

          has_many :refresh_tokens,
                   class_name: 'Oauth2Token::RefreshToken'
        end
      end
    end
  end
end
