# Social Stream migration template
require File.join(Rails.root, File.join('..', '..', 'lib', 'generators', 'social_stream', 'templates', 'migration'))

# Mailboxer migration template
finder = Gem::GemPathSearcher.new
mailboxer_spec = finder.find('mailboxer')
mailboxer_migration =
  finder.matching_files(mailboxer_spec,
                        File.join('generators', 'mailboxer', 'templates', 'migration')).first
require mailboxer_migration

%w( SocialStream Mailboxer ).each do |m|
  begin
    "Create#{ m }".constantize.down
  rescue
    puts "WARNING: #{ m } migration failed to rollback" 
  end
end

CreateMailboxer.up
CreateSocialStream.up

require File.expand_path("../../dummy/db/seeds", __FILE__)
