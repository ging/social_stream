require 'social_stream-base'
require 'social_stream-documents'

module SocialStream
  class Engine < ::Rails::Engine #:nodoc:
    config.app_generators.base 'social_stream:base'
    config.app_generators.documents 'social_stream:documents'
  end
end
