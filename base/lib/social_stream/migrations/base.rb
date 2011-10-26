module SocialStream
  module Migrations
    class Base
      def initialize
        require_old_migration 'acts-as-taggable-on', 'lib/generators/acts_as_taggable_on/migration/templates/active_record/migration'
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
        File.join([get_full_gem_path(gem)], 'db/migrate')
      end

      def require_old_migration(gem,file_path)
        require File.join([get_full_gem_path(gem),file_path])
      end

      def get_full_gem_path(gem)
        if (Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.8.0'))
          return Gem::Specification.find_by_name(gem).full_gem_path
        else
          return Gem::GemPathSearcher.new.find(gem).full_gem_path
        end
      end
    end
  end
end
