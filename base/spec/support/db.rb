require 'social_stream/migrations/base'

SocialStream::Migrations::Base.new.down

SocialStream::Migrations::Base.new.up

require File.expand_path("../../dummy/db/seeds", __FILE__)
