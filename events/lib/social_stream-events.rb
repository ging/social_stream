require 'social_stream-base'

module SocialStream
  module Events
    # Add :document to SocialStream.objects and SocialStream.activity_forms by default
    # It can be configured by users at application's config/initializers/social_stream.rb
    [:event, :agenda, :session].each do |o|
      SocialStream.objects.push(o) unless SocialStream.objects.include?(o)
    end
    
    SocialStream.activity_forms.push(:event) unless SocialStream.objects.include?(:event)
  end
end

require 'social_stream/events/engine'
