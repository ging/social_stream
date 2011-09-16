require 'social_stream-base'

module SocialStream
  module Documents
    # Add :document to SocialStream.objects and SocialStream.activity_forms by default
    # It can be configured by users at application's config/initializers/social_stream.rb
    %w(objects activity_forms).each do |m|
      SocialStream.__send__(m).push(:document) unless SocialStream.__send__(m).include?(:document)
    end
  end
end

#require 'paperclip_processors/ffmpeg'
require 'paperclip-ffmpeg'
require 'social_stream/documents/engine'
