# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'oauth2_server', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream-oauth2_server"
  s.version = SocialStream::Oauth2Server::VERSION.dup
  s.authors = ["Antonio Tapiador", "GING - DIT - UPM"]
  s.summary = "OAuth2 server support for Social Stream, the framework for building social network websites"
  s.description = "Social Stream is a Ruby on Rails engine providing your application with social networking features and activity streams.\n\nThis gem supplies with OAuth2 server support"
  s.email = "social-stream@dit.upm.es"
  s.homepage = "http://github.com/ging/social_stream-oauth2_server"
  s.files = `git ls-files`.split("\n")

  # Gem dependencies
  s.add_runtime_dependency('social_stream-base', '~> 2.0.0')
  s.add_runtime_dependency('rack-oauth2', '~> 1.0.0')

  s.add_development_dependency('rspec-rails', '~> 2.8.0')
end
