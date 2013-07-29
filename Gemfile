source "http://rubygems.org"

# Uncomment the following lines if you are planing to
# use a local code of any of these gems

# Travis' bundler does not properly resolve dependencies for railties
gem 'rails', '3.2.14'

# Gems before social_stream-base
# gem 'mailboxer', :path => '../mailboxer'
# gem 'avatars_for_rails', :path => '../avatars_for_rails'
# gem 'rails-scheduler', path: '../rails-scheduler'
# gem 'omniauth-socialstream', path: '../omniauth-socialstream'
# gem 'flashy', path: '../flashy'

# Needs the libsndfile package
gem 'paperclip_waveform'

# social_stream gems
%w(base documents events linkser presence).each do |g|
  gem "social_stream-#{ g }", :path => g
end

gemspec
