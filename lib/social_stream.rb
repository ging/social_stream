require 'social_stream-base'
require 'social_stream-documents'
require 'social_stream-events'

module SocialStream
  class Engine < ::Rails::Engine #:nodoc:
    config.app_generators.base      'social_stream:base'
    config.app_generators.documents 'social_stream:documents'
    config.app_generators.events    'social_stream:events'
  end
end
