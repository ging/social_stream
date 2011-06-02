require 'social_stream-base'

module SocialStream
  class Engine < ::Rails::Engine #:nodoc:
    config.app_generators.base 'social_stream:base'
  end
end
