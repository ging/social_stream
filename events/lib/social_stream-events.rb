require 'social_stream-base'

require 'rails-scheduler'

module SocialStream
  module Events
    autoload :Ability, 'social_stream/events/ability'

    module Models
      autoload  :Actor,    'social_stream/events/models/actor'
    end

    SocialStream.objects.push(:event) unless SocialStream.objects.include?(:event)
  end
end

require 'social_stream/events/engine'
