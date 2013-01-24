require 'social_stream-base'

require 'gmaps4rails'
require 'geocoder'

module SocialStream
  module Places
  	module Models
  		autoload  :ActivityObject,    'social_stream/places/models/activity_object'
  	end
  	
    SocialStream.objects.push(:place) unless SocialStream.objects.include?(:place)
  end
end

require 'social_stream/places/engine'
