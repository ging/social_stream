# encoding UTF-8
require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'ostatus', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream-ostatus"
  s.version = SocialStream::Ostatus::VERSION.dup
  s.authors = ["Antonio Tapiador", "GING - DIT - UPM"]
  s.summary = "Provides a Social Stream node with social network federation support via OStatus protocol"
  s.description = "This gem allow you to connect several social stream nodes using PSHB hubs, also allows to follow, and share streams with social stream users in any node."
  s.email = "social-stream@dit.upm.es"
  s.homepage = "http://social-stream.dit.upm.es"
  s.files = `git ls-files`.split("\n")

  # Gem dependencies
  s.add_runtime_dependency('social_stream-base','~> 0.22.0')
  s.add_runtime_dependency('proudhon','>= 0.3.5')
  s.add_runtime_dependency('nokogiri','> 1.4.4')
  
  # Development Gem dependencies
  s.add_development_dependency('sqlite3-ruby')
  if RUBY_VERSION < '1.9'
    s.add_development_dependency('ruby-debug')
  end
  s.add_development_dependency('rspec-rails')
  s.add_development_dependency('factory_girl')
  s.add_development_dependency('forgery')
  s.add_development_dependency('capybara')
end
