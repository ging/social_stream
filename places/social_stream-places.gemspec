# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'places', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream-places"
  s.version = SocialStream::Places::VERSION.dup
  s.authors = ["Carolina Garcia", "GING - DIT - UPM"]
  s.summary = "Places support for Social Stream, the core for building social network websites"
  s.description = "Social Stream is a Ruby on Rails engine providing your application with social networking features and activity streams.\n\nThis gem allow you to add places as a new social stream activity"
  s.email = "holacarol@gmail.com"
  s.homepage = "http://github.com/ging/social_stream-places"
  s.files = `git ls-files`.split("\n")

  # Gem dependencies
  s.add_runtime_dependency('social_stream-base', '~> 2.0.0.beta3')
  s.add_runtime_dependency('gmaps4rails','~> 1.5.2')
  s.add_runtime_dependency('geocoder')

  # Development Gem dependencies
end
