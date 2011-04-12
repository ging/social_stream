require File.join(File.dirname(__FILE__), 'migrations')

begin
  ActsAsTaggableOnMigration.down
rescue
  puts "WARNING: ActsAsTaggableOnMigration failed to rollback" 
end

%w(SocialStream Mailboxer).each do |m|
  begin
    "Create#{ m }".constantize.down
  rescue
    puts "WARNING: #{ m } migration failed to rollback" 
  end
end

CreateMailboxer.up
CreateSocialStream.up
ActsAsTaggableOnMigration.up

require File.expand_path("../../dummy/db/seeds", __FILE__)
