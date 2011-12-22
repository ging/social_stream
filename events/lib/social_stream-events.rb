require 'social_stream-base'

require 'rails-scheduler'

module SocialStream
  module Views
    module Settings
      autoload :Events, 'social_stream/views/settings/events'
    end

    module Sidebar
      autoload :Events, 'social_stream/views/sidebar/events'
    end
  end

  module Events
    autoload :Ability, 'social_stream/events/ability'

    module Models
      autoload  :Actor, 'social_stream/events/models/actor'
    end

    SocialStream.objects.push(:event) unless SocialStream.objects.include?(:event)
  end
end

require 'social_stream/events/engine'
