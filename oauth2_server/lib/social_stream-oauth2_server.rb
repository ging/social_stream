require 'social_stream-base'

require 'rack/oauth2'

module SocialStream
  module Oauth2Server
    module Controllers
      autoload :Helpers,  'social_stream/oauth2_server/controllers/helpers'
    end

    module Models
      autoload :User, 'social_stream/oauth2_server/models/user'
    end
    autoload :TokenEndpoint, 'social_stream/oauth2_server/token_endpoint'
  end
end

require 'social_stream/oauth2_server/engine'
