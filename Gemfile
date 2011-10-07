source "http://rubygems.org"

# Uncomment the following lines if you are planing to
# use a local code of any of these gems

# Gems before social_stream-base
# gem 'mailboxer', :path => '../mailboxer'
# gem 'avatars_for_rails', :path => '../avatars_for_rails'

# social_stream gems
%w(base documents).each do |g|
  gem "social_stream-#{ g }", :path => g
end

# gem 'social2social', :path => '../social2social'

gemspec

group :test do
  case ENV['DB']
  when 'mysql'
    gem 'mysql2'
  when 'postgres'
    gem 'pg'
  end
end
