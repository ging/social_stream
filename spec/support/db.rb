# Social Stream migration template
require File.join(Rails.root, File.join('..', '..', 'lib', 'generators', 'social_stream', 'templates', 'migration'))

# Adding acts_as_taggable_on
finder = Gem::GemPathSearcher.new
taggable_spec = finder.find('acts-as-taggable-on')
taggable_migration = finder.matching_files(taggable_spec,
File.join("generators","acts_as_taggable_on","migration","templates","active_record","migration")).first
require taggable_migration

# Mailboxer migration template
finder = Gem::GemPathSearcher.new
mailboxer_spec = finder.find('mailboxer')
mailboxer_migration =
  finder.matching_files(mailboxer_spec,
                        File.join('generators', 'mailboxer', 'templates', 'migration')).first
require mailboxer_migration

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
