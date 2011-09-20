require 'social_stream/migrations/documents'

SocialStream::Migrations::Documents.new.down
SocialStream::Migrations::Base.new.down

SocialStream::Migrations::Base.new.up
SocialStream::Migrations::Documents.new.up
