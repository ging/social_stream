source "http://rubygems.org"

# Uncomment the following lines if you are planing to
# use a local code of any of these gems

# Gems before social_stream-base
# gem 'mailboxer', :path => '../mailboxer'
# gem 'avatars_for_rails', :path => '../avatars_for_rails'

# social_stream gems
%w(social_stream-base social_stream-documents social2social).each do |g|
  if File.exists?(File.join(File.dirname(__FILE__), '..', g))
    gem g, :path => File.join('..', g)
  end
end

gemspec
