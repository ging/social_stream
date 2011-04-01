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
  end
end

require 'social_stream'
require 'social2social/engine'
require 'railtie.rb'
