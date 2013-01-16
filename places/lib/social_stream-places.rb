require 'social_stream-base'

module SocialStream
  module Views
  end

  module Places
    SocialStream.objects.push(:place) unless SocialStream.objects.include?(:place)
  end
end

require 'social_stream/places/engine'
