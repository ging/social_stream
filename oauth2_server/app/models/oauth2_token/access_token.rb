class Oauth2Token::AccessToken < Oauth2Token
  self.default_lifetime = 15.minutes

  belongs_to :refresh_token,
             class_name: "Oauth2Token::RefreshToken"

  def to_bearer_token(with_refresh_token = false)
    bearer_token = Rack::OAuth2::AccessToken::Bearer.new(
      access_token: token,
      expires_in:   expires_in
    )

    if with_refresh_token
      bearer_token.refresh_token = create_refresh_token!(
        user: user,
        client: client
      ).token
    end

    bearer_token
  end

  def setup
    super

    if refresh_token
      self.user       = refresh_token.user
      self.client     = refresh_token.client
      self.expires_at = [ expires_at, refresh_token.expires_at ].min
    end
  end
end
