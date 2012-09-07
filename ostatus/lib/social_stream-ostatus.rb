require 'social_stream-base'

# Ruby implementation of OStatus
require 'proudhon'

module SocialStream
  module Ostatus
    mattr_accessor :hub
    @@hub = :hub
    
    mattr_accessor :node_base_url
    @@node_base_url = :node_base_url

    mattr_accessor :pshb_host
    @@node_base_url = :pshb_host
   
    class << self
      def setup 
        yield self
      end
    end

    module Models
      autoload :Actor, 'social_stream/ostatus/models/actor'
      autoload :Audience, 'social_stream/ostatus/models/audience'
      module Relation
        autoload :Custom, 'social_stream/ostatus/models/relation/custom'
      end
    end
  end
end

require 'social_stream/ostatus/engine'
