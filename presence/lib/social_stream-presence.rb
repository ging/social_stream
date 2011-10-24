require 'social_stream-base'

module SocialStream
  module Presence   

    module Models
      autoload :BuddyManager, 'social_stream/presence/models/buddy_manager'
    end

    mattr_accessor :domain
    mattr_accessor :bosh_service
    mattr_accessor :password
    mattr_accessor :xmpp_server_password
    mattr_accessor :social_stream_presence_username
    mattr_accessor :enable
    @@enable = true
    
    class << self
      def setup
        yield self
      end
    end

  end
end

require 'social_stream/presence/engine'