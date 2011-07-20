require File.join(File.dirname(__FILE__), 'migrations')


begin
  ActsAsTaggableOnMigration.down
rescue
  puts "WARNING: ActsAsTaggableOnMigration failed to rollback"
end

mailboxer_path = Gem::GemPathSearcher.new.find('mailboxer').full_gem_path
mailboxer_migration = File.join([mailboxer_path,'db', 'migrate'])

begin
  ActiveRecord::Migrator.migrate mailboxer_migration, 0
rescue
  puts "WARNING: Mailboxer migration failed to rollback"
end

begin
  ActiveRecord::Migrator.migrate File.expand_path("../../dummy/db/migrate/", __FILE__), 0
rescue
  puts "WARNING: Social Stream Base failed to rollback"
end


ActsAsTaggableOnMigration.up

ActiveRecord::Migrator.migrate mailboxer_migration

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../../dummy/db/migrate/", __FILE__)

require File.expand_path("../../dummy/db/seeds", __FILE__)
