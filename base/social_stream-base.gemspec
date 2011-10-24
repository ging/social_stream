# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'base', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream-base"
  s.version = SocialStream::Base::VERSION.dup
  s.summary = "Basic features for Social Stream, the core for building social network websites"
  s.description = "Social Stream is a Ruby on Rails engine providing your application with social networking features and activity streams.\n\nThis gem packages the basic functionality, along with basic actors (user, group) and activity objects (post and comments)"
  s.authors = [ "GING - DIT - UPM",
                "CISE - ESPOL" ]
  s.homepage = "http://social-stream.dit.upm.es/"
  s.files = `git ls-files`.split("\n")

  # Runtime gem dependencies
  #
  # Rails
  s.add_runtime_dependency('rails', '>= 3.1.0')
  # Activity and Relation hierarchies
  s.add_runtime_dependency('ancestry', '~> 1.2.3')
  # SQL foreign keys
  s.add_runtime_dependency('foreigner', '~> 0.9.1')
  # Authentication
  s.add_runtime_dependency('devise', '~> 1.4.5')
  # CRUD controllers
  s.add_runtime_dependency('inherited_resources', '~> 1.3.0')
  # Slug generation
  s.add_runtime_dependency('stringex', '~> 1.3.0')
  # Avatar attachments
  s.add_runtime_dependency('avatars_for_rails', '~> 0.2.0')
  # jQuery
  s.add_runtime_dependency('jquery-rails', '~> 1.0.9')
  # Authorization
  s.add_runtime_dependency('cancan', '~> 1.6.4')
  # Pagination
  s.add_runtime_dependency('kaminari', '~> 0.12.4')
  # OAuth client
  s.add_runtime_dependency('omniauth','~> 0.2.6')
  # OAuth provider
  s.add_runtime_dependency('oauth-plugin','~> 0.4.0.pre1')	
  # Messages
  s.add_runtime_dependency('mailboxer','~> 0.5.4')
  # Tagging
  s.add_runtime_dependency('acts-as-taggable-on','~> 2.0.6')
  # HTML Forms
  s.add_runtime_dependency('formtastic','~> 1.2.3')
  # Simple navigation for menu
  s.add_runtime_dependency('simple-navigation')
  # Background jobs
  s.add_runtime_dependency('resque','~> 1.17.1')
  # Modernizr.js javascript library
  s.add_runtime_dependency('modernizr-rails', '~> 2.0.6')
  # Sphinx search engine
  s.add_runtime_dependency('thinking-sphinx', '~> 2.0.8')
  #Syntactically Awesome Stylesheets
  s.add_runtime_dependency('sass-rails', '~> 3.1.0')

  # Development gem dependencies
  #
  # Integration testing
  s.add_development_dependency('capybara', '~> 0.3.9')
  # Testing database
  s.add_development_dependency('sqlite3-ruby')
  # Debugging
  if RUBY_VERSION < '1.9'
    s.add_development_dependency('ruby-debug')
  else
    s.add_development_dependency('ruby-debug19')
  end
  # Specs
  s.add_development_dependency('rspec-rails', '~> 2.6.1')
  # Fixtures
  s.add_development_dependency('factory_girl', '~> 1.3.2')
  # Population
  s.add_development_dependency('forgery', '~> 0.4.2')
  # Continous integration
  s.add_development_dependency('ci_reporter', '~> 1.6.4')
  # Scaffold generator
  s.add_development_dependency('nifty-generators','~> 0.4.5')
end
