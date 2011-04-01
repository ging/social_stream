# Use Social Stream migration template
path = %w( .. .. .. lib generators social_stream templates migration )
path.unshift File.dirname(__FILE__)

require File.join(*path)

# Adding acts_as_taggable_on
finder = Gem::GemPathSearcher.new
taggable_spec = finder.find('acts-as-taggable-on')
taggable_migration = finder.matching_files(taggable_spec,
                                         File.join("generators","acts_as_taggable_on","migration","templates","active_record","migration")).first
require taggable_migration

# Use Mailboxer migration template
finder = Gem::GemPathSearcher.new
mailboxer_spec = finder.find('mailboxer')
mailboxer_migration =
  finder.matching_files(mailboxer_spec,
                        File.join("generators", "mailboxer", "templates", "migration")).first
require mailboxer_migration

ActiveRecord::Schema.define(:version => 0) do
  CreateMailboxer.up
  CreateSocialStream.up
  ActsAsTaggableOnMigration.up
end
