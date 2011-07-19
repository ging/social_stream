require File.join(File.dirname(__FILE__), '..', '..', 'support', 'migrations')

ActiveRecord::Schema.define(:version => 0) do
  # Mailboxer
  mailboxer_path = Gem::GemPathSearcher.new.find('mailboxer').full_gem_path
  mailboxer_migration = File.join([mailboxer_path,'db', 'migrate'])
  ActiveRecord::Migrator.migrate mailboxer_migration
  #SocialStream
  CreateSocialStream.up
  #ActAsTaggable
  ActsAsTaggableOnMigration.up
end
