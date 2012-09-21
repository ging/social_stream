require 'social_stream-base'

# Ruby implementation of OStatus
require 'proudhon'

module SocialStream
  module Ostatus
    # PuSH hub
    mattr_accessor :hub
    # Default to the PubSubHubbub reference Hub server
    @@hub = 'http://pubsubhubbub.appspot.com'
    
    # The host where the hub should take the activity feed from
    mattr_accessor :activity_feed_host
    @@activity_feed_host = 'localhost:3000'

    # The host where the PuSH should send the callbacks to
    mattr_accessor :pshb_host
    @@pshb_host = 'localhost:3000'

    # Debug OStatus request with logger.info
    mattr_accessor :debug_requests
    @@debug_requests = false
  
    class << self
      def setup 
        yield self
      end
    end

    autoload :ActivityStreams, 'social_stream/ostatus/activity_streams'

    module Models
      autoload :Activity, 'social_stream/ostatus/models/activity'
      autoload :Actor, 'social_stream/ostatus/models/actor'
      autoload :Audience, 'social_stream/ostatus/models/audience'
      autoload :Tie, 'social_stream/ostatus/models/tie'

      module Object
        autoload :ClassMethods, 'social_stream/ostatus/models/object'
      end

      module Relation
        autoload :Custom, 'social_stream/ostatus/models/relation/custom'
      end
    end
    
    module Controllers
      autoload :DebugRequests, 'social_stream/ostatus/controllers/debug_requests'
    end
  end
end

require 'social_stream/ostatus/engine'
