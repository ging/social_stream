require 'social_stream-base'

require 'linkser'

module SocialStream
  module Linkser
    # Add :link to SocialStream.objects and others by default
    # It can be configured by users at application's config/initializers/social_stream.rb
    %w(objects activity_forms quick_search_models extended_search_models repository_models).each do |m|
      SocialStream.__send__(m).push(:link) unless SocialStream.__send__(m).include?(:link)
    end
  end
end

require 'social_stream/linkser/engine'
