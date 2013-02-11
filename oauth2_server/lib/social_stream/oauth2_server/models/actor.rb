module SocialStream
  module Oauth2Server
    module Models
      module Actor
        def developer_site_clients
          Site::Client.administered_by(self)
        end
      end
    end
  end
end
