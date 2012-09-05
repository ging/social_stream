require 'social_stream-base'

module SocialStream
  module Ostatus
    mattr_accessor :hub
    @@hub = :hub
    
    mattr_accessor :node_base_url
    @@node_base_url = :node_base_url
    
    class << self
      def setup 
        yield self
      end
    end

    module Models
      autoload :Actor, 'social_stream/ostatus/models/actor'
      autoload :Audience, 'social_stream/ostatus/models/audience'
    end
  end
end

require 'social_stream/ostatus/engine'
