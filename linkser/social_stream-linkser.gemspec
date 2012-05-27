# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'linkser', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream-linkser"
  s.version = SocialStream::Linkser::VERSION.dup
  s.authors = ["Eduardo Casanova Cuesta", "GING - DIT - UPM"]
  s.summary = "Social Stream Linkser provides Linkser support in Social Stream."
  s.description = "Social Stream Linkser provides Linkser support in Social Stream, the core for building social network websites."
  s.email = "ecasanovac@gmail.com"
  s.homepage = "http://github.com/ging/social_stream-linkser"
  s.files = `git ls-files`.split("\n")

  # Gem dependencies
  s.add_runtime_dependency('social_stream-base', '~> 0.21.0')
  s.add_runtime_dependency('linkser', '~> 0.0.12')
  # Development Gem dependencies
  s.add_development_dependency('sqlite3-ruby')
  if RUBY_VERSION < '1.9'
    s.add_development_dependency('ruby-debug', '~> 0.10.3')
  end
  s.add_development_dependency('rspec-rails', '~> 2.6.0')
  s.add_development_dependency('factory_girl', '~> 1.3.2')
  s.add_development_dependency('forgery', '~> 0.3.6')
  s.add_development_dependency('capybara', '~> 0.3.9')
end
