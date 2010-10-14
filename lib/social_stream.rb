require 'social_stream/railtie'
require 'social_stream/seed'

# Provides your Rails application with social network and activity stream support
module SocialStream
  mattr_accessor :actors
  @@actors = []

  mattr_accessor :activity_objects
  @@activity_objects = []

  class << self
    def setup
      yield self
    end

    def seed!
      Seed.new("#{ Rails.root }/db/seeds/social_stream.yml")
    end
  end
end
