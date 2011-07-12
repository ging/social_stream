require File.join(File.dirname(__FILE__), 'migrations')

begin
  ActsAsTaggableOnMigration.down
rescue
  puts "WARNING: ActsAsTaggableOnMigration failed to rollback" 
end

%w(Mailboxer).each do |m|
  begin
    "Create#{ m }".constantize.down
  rescue
    puts "WARNING: #{ m } migration failed to rollback" 
  end
end

begin
  ActiveRecord::Migrator.migrate File.expand_path("../../dummy/db/migrate/", __FILE__), 0
rescue
  puts "WARNING: Social Stream Base failed to rollback" 
end

CreateMailboxer.up
ActsAsTaggableOnMigration.up

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../../dummy/db/migrate/", __FILE__)

require File.expand_path("../../dummy/db/seeds", __FILE__)
