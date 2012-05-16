require 'social_stream-base'

module SocialStream
  module Views
    module Settings
      autoload :Presence, 'social_stream/views/settings/presence'
    end

    module Toolbar
      autoload :Presence, 'social_stream/views/toolbar/presence'
    end
  end

  module Presence   
    autoload :VERSION, 'social_stream/presence/version'

    autoload :XmppServerOrder, 'social_stream/presence/xmpp_server_order'

    module Models
      autoload :BuddyManager, 'social_stream/presence/models/buddy_manager'
      autoload :GroupManager, 'social_stream/presence/models/group_manager'
    end

    mattr_accessor :domain
    mattr_accessor :bosh_service
    mattr_accessor :auth_method
    mattr_accessor :xmpp_server_password
    mattr_accessor :secure_rest_api
    mattr_accessor :remote_xmpp_server
    mattr_accessor :scripts_path
    mattr_accessor :ejabberd_module_path
    mattr_accessor :enable
    
    mattr_accessor :ssh_domain
    mattr_accessor :ssh_user
    mattr_accessor :ssh_password
    
    mattr_accessor :social_stream_presence_username
    mattr_accessor :password
    
    mattr_accessor :opentok_api_key
    mattr_accessor :opentok_api_secret
    
    mattr_accessor :games

    @@auth_method = "cookie"
    @@remote_xmpp_server = false
    @@secure_rest_api = false
    @@enable = false
    @@social_stream_presence_username = "social_stream_presence"
    @@opentok_api_key = "default"
    @@games = false
    
    class << self
      def setup
        yield self
      end
    end

  end
end

require 'social_stream/presence/engine'
