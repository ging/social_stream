require 'social_stream/migration_finder'

# acts-as-taggable-on
SocialStream::MigrationFinder.new 'acts-as-taggable-on',
                    ["generators", "acts_as_taggable_on", "migration", "templates", "active_record", "migration"]

