# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'base', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream-base"
  s.version = SocialStream::Base::VERSION.dup
  s.summary = "Basic features for Social Stream, the core for building social network websites"
  s.description = "Social Stream is a Ruby on Rails engine providing your application with social networking features and activity streams.\n\nThis gem packages the basic functionality, along with basic actors (user, group) and activity objects (post and comments)"
  s.authors = [ "GING - DIT - UPM" ]
  s.homepage = "http://social-stream.dit.upm.es/"
  s.files = `git ls-files`.split("\n")
  s.license = 'MIT'

  # Runtime gem dependencies
  #
  # Do not forget to require the file at lib/social_stream/base/dependencies !
  #
  # Deep Merge support for Hashes
  s.add_runtime_dependency('deep_merge')
  # Rails
  s.add_runtime_dependency('rails', '>= 3.1.0')
  # Rails Engine Decorators
  s.add_runtime_dependency('rails_engine_decorators')
  # Activity and Relation hierarchies
  s.add_runtime_dependency('ancestry', '~> 1.2.3')
  # SQL foreign keys
  s.add_runtime_dependency('foreigner', '~> 1.1.1')
  # Authentication
  s.add_runtime_dependency('devise', '~> 2.2.3')
  # CRUD controllers
  s.add_runtime_dependency('inherited_resources', '~> 1.4.0')
  # Slug generation
  s.add_runtime_dependency('stringex', '~> 1.5.1')
  # Avatar attachments
  s.add_runtime_dependency('avatars_for_rails', '~> 1.1.4')
  # jQuery
  s.add_runtime_dependency('jquery-rails', '>= 3.0.0')
  # jQuery UI
  s.add_runtime_dependency('jquery-ui-rails', '>= 4.0.3')
  # Select2 javascript library
  s.add_runtime_dependency('select2-rails', '~> 3.3.0')
  # Authorization
  s.add_runtime_dependency('cancan', '~> 1.6.7')
  # Pagination
  s.add_runtime_dependency('kaminari', '~> 0.13.0')
  # OAuth client
  s.add_runtime_dependency('omniauth-socialstream', '~> 0.1.2')
  s.add_runtime_dependency('omniauth-facebook','~> 1.4.1')
  s.add_runtime_dependency('omniauth-linkedin','~> 0.0.6')
  # Messages
  s.add_runtime_dependency('mailboxer','~> 0.10.3')
  # Tagging
  s.add_runtime_dependency('acts-as-taggable-on','~> 2.4.1')
  # Background jobs
  s.add_runtime_dependency('resque','~> 1.23.0')
  # Modernizr.js javascript library
  s.add_runtime_dependency('modernizr-rails', '~> 2.0.6')
  # Sphinx search engine
  s.add_runtime_dependency('thinking-sphinx', '~> 2.0.8')
  # Syntactically Awesome Stylesheets
  s.add_runtime_dependency('sass-rails', '>= 3.1.0')
  # Bootstrap for Sass
  s.add_runtime_dependency('bootstrap-sass', '~> 2.3.2.0')
  # Customize ERB views
  s.add_runtime_dependency('deface', '~> 0.9.1')
  # Autolink text blocks
  s.add_runtime_dependency('rails_autolink', '~> 1.0.4')
  # I18n-js
  s.add_runtime_dependency('i18n-js','~>2.1.2')
  # Strong Parameters
  s.add_runtime_dependency('strong_parameters','~> 0.2.1')
  # Flash messages
  s.add_runtime_dependency('flashy','~> 0.0.1')

  # Development gem dependencies
  #
  # Integration testing
  s.add_development_dependency('capybara', '~> 0.3.9')
  # Testing database
  s.add_development_dependency('sqlite3-ruby')
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
  # pry
  s.add_development_dependency('pry-rails','~> 0.4.5')

end
