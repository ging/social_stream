source "http://rubygems.org"

# Freeze rails version
# https://github.com/ging/social_stream/issues/291
gem 'rails', '3.2.8'

# Uncomment the following lines if you are planing to
# use a local code of any of these gems

# Gems before social_stream-base
# gem 'mailboxer', :path => '../mailboxer'
# gem 'avatars_for_rails', :path => '../avatars_for_rails'

# social_stream gems
%w(base documents events linkser presence).each do |g|
  gem "social_stream-#{ g }", :path => g
end

# gem 'social2social', :path => '../social2social'

gemspec
