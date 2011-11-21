require 'social_stream/migrations/linkser'


SocialStream::Migrations::Linkser.new.down
SocialStream::Migrations::Base.new.down

SocialStream::Migrations::Base.new.up
SocialStream::Migrations::Linkser.new.up
