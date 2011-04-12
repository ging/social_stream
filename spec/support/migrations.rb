# Social Stream migration template
social_stream_migration =
  File.join(File.dirname(__FILE__), '..', '..', 'lib', 'generators', 'social_stream', 'templates', 'migration')

require social_stream_migration

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


