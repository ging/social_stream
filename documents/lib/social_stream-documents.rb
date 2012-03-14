require 'social_stream/documents/dependencies'

module SocialStream
  module Views
    module Toolbar
      autoload :Documents, 'social_stream/views/toolbar/documents'
    end
  end

  module Documents
    # Add :document to SocialStream.objects and SocialStream.activity_forms by default
    # It can be configured by users at application's config/initializers/social_stream.rb
    [ :picture, :video, :audio, :document].each do |o|
    SocialStream.quick_search_models.push(o) unless SocialStream.quick_search_models.include?(o)
    SocialStream.extended_search_models.push(o) unless SocialStream.extended_search_models.include?(o)
    end
    
    %w(objects activity_forms).each do |m|
      SocialStream.__send__(m).push(:document) unless SocialStream.__send__(m).include?(:document)
    end
  end
end

require 'social_stream/documents/engine'
