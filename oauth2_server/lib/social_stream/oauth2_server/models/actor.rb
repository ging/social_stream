module SocialStream
  module Oauth2Server
    module Models
      module Actor
        def managed_site_clients
          Site::Client.managed_by(self)
        end
      end
    end
  end
end
