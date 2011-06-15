require 'social_stream-base'
require 'social_stream-attachments'

module SocialStream
  class Engine < ::Rails::Engine #:nodoc:
    config.app_generators.base 'social_stream:base'
  end
end
