require 'social_stream-base'
require 'conference_manager-ruby'

module SocialStream
  module ToolbarConfig
    autoload :Events, 'social_stream/toolbar_config/events'
  end

  module Events
    # Add :event, :agenda, :session to SocialStream's subjects, objects and activity_forms
    # by default
    # It can be configured by users at application's config/initializers/social_stream.rb
    SocialStream.subjects.push(:event) unless SocialStream.subjects.include?(:event)
    
    SocialStream.quick_search_models.push(:event) unless SocialStream.quick_search_models.include?(:event)
    SocialStream.extended_search_models.push(:event) unless SocialStream.extended_search_models.include?(:event)

    [ :agenda, :session ].each do |o|
      SocialStream.objects.push(o) unless SocialStream.objects.include?(o)
    end
    
    SocialStream.activity_forms.push(:event) unless SocialStream.activity_forms.include?(:event)
  end
end

require 'social_stream/events/engine'
