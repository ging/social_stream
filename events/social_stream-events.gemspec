# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'events', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream-events"
  s.version = SocialStream::Events::VERSION.dup
  s.authors = ["Antonio Tapiador", "GING - DIT - UPM"]
  s.summary = "Scheduled events support for Social Stream, the core for building social network websites"
  s.description = "Social Stream is a Ruby on Rails engine providing your application with social networking features and activity streams.\n\nThis gem allow you to add events as a new social stream activity, with a calendar-supported management"
  s.email = "social-stream@dit.upm.es"
  s.homepage = "http://github.com/ging/social_stream-events"
  s.files = `git ls-files`.split("\n")

  # Gem dependencies
  s.add_runtime_dependency('social_stream-base', '~> 0.21.0')
  s.add_runtime_dependency('rails-scheduler', '~> 0.0.8')

  # Development Gem dependencies
  s.add_development_dependency('sqlite3-ruby')
  if RUBY_VERSION < '1.9'
    s.add_development_dependency('ruby-debug', '~> 0.10.3')
  end
end
