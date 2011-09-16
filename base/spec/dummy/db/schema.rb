require 'social_stream/migrations/base'

ActiveRecord::Schema.define(:version => 0) do
  SocialStream::Migrations::Base.new.up
end
