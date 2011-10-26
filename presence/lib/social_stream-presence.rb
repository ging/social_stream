require 'social_stream-base'

module SocialStream
  module Presence   

    autoload :XmppServerOrder, 'social_stream/presence/xmpp_server_order'

    module Models
      autoload :BuddyManager, 'social_stream/presence/models/buddy_manager'
    end

    mattr_accessor :bosh_service
    mattr_accessor :xmpp_server_password
    mattr_accessor :remote_xmpp_server
    mattr_accessor :enable
    
    mattr_accessor :domain
    mattr_accessor :social_stream_presence_username
    mattr_accessor :password

    mattr_accessor :scripts_path

    @@enable = true
    @@remote_xmpp_server = false
    
    class << self
      def setup
        yield self
      end
    end

  end
end

require 'social_stream/presence/engine'