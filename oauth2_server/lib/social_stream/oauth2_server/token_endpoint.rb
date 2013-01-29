module SocialStream
  module Oauth2Server
    class TokenEndpoint
      def call(env)
        authenticator.call(env)
      end

      private

      def authenticator
        Rack::OAuth2::Server::Token.new do |req, res|
        client = Site::Client.find(req.client_id) || req.invalid_client!
        client.secret == req.client_secret || req.invalid_client!

        case req.grant_type
        when :authorization_code
          code = Oauth2Token::AuthorizationCode.valid.find_by_token(req.code)
          req.invalid_grant! if code.blank? || code.redirect_uri != req.redirect_uri

          res.access_token = code.access_token.to_bearer_token(:with_refresh_token)
        when :password
          # TODO
          account = Account.find_by_username_and_password(req.username, req.password) || req.invalid_grant!
          res.access_token = account.access_tokens.create(:client => client).to_bearer_token(:with_refresh_token)
        when :client_credentials
          # NOTE: client is already authenticated here.
          res.access_token = client.access_tokens.create!.to_bearer_token
        when :refresh_token
          refresh_token = client.refresh_tokens.valid.find_by_token(req.refresh_token)
          req.invalid_grant! unless refresh_token
          res.access_token = refresh_token.access_tokens.create!.to_bearer_token
        else
          # NOTE: extended assertion grant_types are not supported yet.
          req.unsupported_grant_type!
        end
        end
      end
    end
  end
end

