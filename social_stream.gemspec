require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream"
  s.version = SocialStream::VERSION.dup
  s.summary = "Social networking features and activity streams for Ruby on Rails."
  s.description = "Ruby on Rails engine supporting social networking features and activity streams."
  s.authors = [ "GING - DIT - UPM",
                "CISE - ESPOL" ]
  s.homepage = "http://social-stream.dit.upm.es/"
  s.files = `git ls-files`.split("\n")

  # Gem dependencies
  #
  # Activity and Relation hierarchies
  s.add_runtime_dependency('ancestry', '~> 1.2.3')
  # SQL foreign keys
  s.add_runtime_dependency('foreigner', '~> 0.9.1')
  # Authentication
  s.add_runtime_dependency('devise', '~> 1.2.rc')
  # CRUD controllers
  s.add_runtime_dependency('inherited_resources', '~> 1.1.2')
  # Slug generation
  s.add_runtime_dependency('stringex', '~> 1.2.0')
  # Avatar attachments
  s.add_runtime_dependency('paperclip', '~> 2.3.4')
  s.add_runtime_dependency('avatars_for_rails', '~> 0.0.9')
  # jQuery
  s.add_runtime_dependency('jquery-rails', '~> 0.2.5')
  # Authorization
  s.add_runtime_dependency('cancan', '~> 1.6.4')
  # Pagination
  s.add_runtime_dependency('will_paginate', '~> 3.0.pre2')
  # OAuth client
  s.add_runtime_dependency('omniauth','~> 0.2.0.beta5')	
  # OAuth provider
  s.add_runtime_dependency('oauth-plugin','~> 0.4.0.pre1')	
  # Theme support
  s.add_runtime_dependency('rails_css_themes','~> 1.0.0')	
  # Messages
  s.add_runtime_dependency('mailboxer','~> 0.1.2')
  # Avatar manipulation
  s.add_runtime_dependency('rmagick','~> 2.13.1')
  # Tagging
  s.add_runtime_dependency('acts-as-taggable-on','~> 2.0.6')
  # HTML Forms
  s.add_runtime_dependency('formtastic','~> 1.2.3')
 
  # Development Gem dependencies
  s.add_development_dependency('rails', '~> 3.0.7')
  # Integration testing
  s.add_development_dependency('capybara', '~> 0.3.9')
  # Testing database
  s.add_development_dependency('sqlite3-ruby')
  # Debugging
  if RUBY_VERSION < '1.9'
    s.add_development_dependency('ruby-debug', '~> 0.10.3')
  end
  # Specs
  s.add_development_dependency('rspec-rails', '~> 2.5.0')
  # Fixtures
  s.add_development_dependency('factory_girl', '~> 1.3.2')
  # Population
  s.add_development_dependency('forgery', '~> 0.3.6')
  # Continous integration
  s.add_development_dependency('ci_reporter', '~> 1.6.4')
  # Scaffold generator
  s.add_development_dependency('nifty-generators','~> 0.4.5')
end
