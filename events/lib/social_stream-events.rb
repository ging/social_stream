require 'social_stream-base'

require 'rails-scheduler'

module SocialStream
  module Events
    autoload :Ability, 'social_stream/events/ability'

    module Models
      autoload  :Actor,    'social_stream/events/models/actor'
    end

    %w( objects quick_search_models extended_search_models repository_models ).each do |m|
      SocialStream.__send__(m).push(:event) unless SocialStream.__send__(m).include?(:event)
    end
  end
end

require 'social_stream/events/engine'
