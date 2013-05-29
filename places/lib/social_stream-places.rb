require 'social_stream-base'

require 'gmaps4rails'
require 'geocoder'

module SocialStream
  module Places
    module Models
      autoload  :ActivityObject,  'social_stream/places/models/activity_object'
    end
    
    %w( objects quick_search_models extended_search_models repository_models ).each do |m|
      SocialStream.__send__(m).push(:place) unless SocialStream.__send__(m).include?(:place)
    end

  end
end

require 'social_stream/places/engine'
