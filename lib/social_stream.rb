require 'social_stream/seed'

# Provides your Rails application with social network and activity stream support
module SocialStream
  module Models
    autoload :Supertype, 'social_stream/models/supertype'
    autoload :Actor, 'social_stream/models/actor'
    autoload :ActivityObject, 'social_stream/models/activity_object'
  end

  mattr_accessor :actors
  @@actors = []

  mattr_accessor :activity_objects
  @@activity_objects = []

  class << self
    def setup
      yield self
    end

    def seed!
      Seed.new("#{ ::Rails.root }/db/seeds/social_stream.yml")
    end
  end
end

require 'social_stream/rails'
