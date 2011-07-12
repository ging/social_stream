class MigrationFinder
  def initialize gem, path
    finder = Gem::GemPathSearcher.new
    taggable_spec = finder.find(gem)
    taggable_migration = finder.matching_files(taggable_spec,
                                               File.join(*path)).first

    require taggable_migration
  end
end

# acts-as-taggable-on
MigrationFinder.new 'acts-as-taggable-on',
                   ["generators", "acts_as_taggable_on", "migration", "templates", "active_record", "migration"]

# Mailboxer
MigrationFinder.new 'mailboxer',
                    ['generators', 'mailboxer', 'templates', 'migration']

