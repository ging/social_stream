require 'social_stream/migrations/documents'

ActiveRecord::Schema.define(:version => 0) do
  SocialStream::Migrations::Base.new.up
  SocialStream::Migrations::Documents.new.up
end
