class Oauth2Token::RefreshToken < Oauth2Token
  self.default_lifetime = 1.month

  has_many :access_tokens,
           class_name: 'Oauth2Token::AccessToken'

end
