require 'social_stream'

module Social2social
  
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
    autoload :Shareable, 'social2social/models/shareable'
    autoload :UpdateTriggerable, 'social2social/models/updatetriggerable'
  end
end

require 'social2social/engine'
