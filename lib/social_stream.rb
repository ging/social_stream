module SocialStream
  Components = %w{ base documents events linkser presence }

  class Engine < ::Rails::Engine #:nodoc:
    config.app_generators.base      'social_stream:base'
    config.app_generators.documents 'social_stream:documents'
    config.app_generators.events    'social_stream:events'
    config.app_generators.linkser   'social_stream:linkser'
    config.app_generators.chat      'social_stream:presence'
  end
end

SocialStream::Components.each do |component|
  require "social_stream-#{ component }" # require "social_stream-base"
end
