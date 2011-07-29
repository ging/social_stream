module SocialStream
  module Migrations
    # Searches for migrations in a gem and requires them.
    # Example:
    #
    #   MigrationFinder.new 'acts-as-taggable-on',
    #                       ["generators", "acts_as_taggable_on", "migration", "templates", "active_record", "migration"]
    #   ActsAsTaggableOnMigration.up
    class Finder
      def initialize gem, path
        finder = Gem::GemPathSearcher.new
        taggable_spec = finder.find(gem)
        taggable_migration = finder.matching_files(taggable_spec,
                                                   File.join(*path)).first

        require taggable_migration
      end
    end
  end
end
