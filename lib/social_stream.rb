require 'social_stream-base'
require 'social_stream-documents'
require 'social_stream-events'
require 'social_stream-linkser'
require 'social_stream-presence'

module SocialStream
  class Engine < ::Rails::Engine #:nodoc:
    config.app_generators.base      'social_stream:base'
    config.app_generators.documents 'social_stream:documents'
    config.app_generators.events    'social_stream:events'
    config.app_generators.linkser   'social_stream:linkser'
    config.app_generators.chat      'social_stream:presence'
  end
end
