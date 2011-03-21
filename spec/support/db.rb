require File.join(Rails.root, '../../lib/generators/social_stream/templates/migration')

begin
  CreateSocialStream.down
rescue
  puts "WARNING: SocialStream migration failed to rollback"
end

CreateSocialStream.up

require File.expand_path("../../dummy/db/seeds", __FILE__)
