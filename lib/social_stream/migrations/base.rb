require 'social_stream/migrations/finder'

module SocialStream
  module Migrations
    class Base
      def initialize
        find_old_migration 'acts-as-taggable-on',
                       ["generators", "acts_as_taggable_on", "migration", "templates", "active_record", "migration"]

        @mailboxer_migration = find_migration 'mailboxer'
        @base_migration = find_migration 'social_stream-base'
      end

      def up
        ActsAsTaggableOnMigration.up

        ActiveRecord::Migrator.migrate @mailboxer_migration

        # Run any available migration
        ActiveRecord::Migrator.migrate @base_migration
      end

      def down
        begin
          ActiveRecord::Migrator.migrate @base_migration, 0
        rescue
          puts "WARNING: Social Stream Base failed to rollback"
        end

        begin
          ActiveRecord::Migrator.migrate @mailboxer_migration, 0
        rescue
          puts "WARNING: Mailboxer migration failed to rollback"
        end

        begin
          ActsAsTaggableOnMigration.down
        rescue
          puts "WARNING: ActsAsTaggableOnMigration failed to rollback"
        end
      end

      protected

      def find_migration(gem)
        path = Gem::GemPathSearcher.new.find(gem).full_gem_path
        File.join([path,'db', 'migrate'])
      end

      def find_old_migration(gem, path)
        SocialStream::Migrations::Finder.new gem, path
      end
    end
  end
end
