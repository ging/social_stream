require 'social_stream/migration_finder'

# acts-as-taggable-on
SocialStream::MigrationFinder.new 'acts-as-taggable-on',
                    ["generators", "acts_as_taggable_on", "migration", "templates", "active_record", "migration"]

# Mailboxer
mailboxer_path = Gem::GemPathSearcher.new.find('mailboxer').full_gem_path
mailboxer_migration = File.join([mailboxer_path,'db', 'migrate'])
ActiveRecord::Migrator.migrate mailboxer_migration
