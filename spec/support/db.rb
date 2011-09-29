require 'social_stream/migrations/documents'
require 'social_stream/migrations/events'

SocialStream::Migrations::Events.new.down
SocialStream::Migrations::Documents.new.down
SocialStream::Migrations::Base.new.down

SocialStream::Migrations::Base.new.up
SocialStream::Migrations::Documents.new.up
SocialStream::Migrations::Events.new.up
