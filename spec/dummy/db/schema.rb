require File.join(File.dirname(__FILE__), '..', '..', 'support', 'migrations')

ActiveRecord::Schema.define(:version => 0) do
  CreateMailboxer.up
  CreateSocialStream.up
  ActsAsTaggableOnMigration.up
end
