require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream"
  s.version = SocialStream::VERSION.dup
  s.summary = "A core for building social network websites"
  s.description = "Social Stream is a Ruby on Rails engine for building social network websites. It supports contacts, posts, file uploads, private messages and much more."
  s.authors = [ "GING - DIT - UPM",
                "CISE - ESPOL" ]
  s.homepage = "http://social-stream.dit.upm.es/"
  s.files = `git ls-files`.split("\n")

  # Gem dependencies
  s.add_runtime_dependency('social_stream-base', '~> 1.0.0')
  s.add_runtime_dependency('social_stream-documents', '~> 1.0.0')
  s.add_runtime_dependency('social_stream-events', '~> 1.0.0')
  s.add_runtime_dependency('social_stream-linkser', '~> 1.0.0')
  s.add_runtime_dependency('social_stream-presence', '~> 1.0.0')
  s.add_runtime_dependency('social_stream-ostatus', '~> 1.0.0')
 
  # Development Gem dependencies
  #
  # Integration testing
  s.add_development_dependency('capybara', '~> 0.3.9')
  # Testing database
  case ENV['DB']
  when 'mysql'
    s.add_development_dependency('mysql2')
  when 'postgres'
    # Freeze pg version to 0.12.0
    # https://t.co/zKY52Efr
    s.add_development_dependency('pg', '0.12.0')
  else
    s.add_development_dependency('sqlite3')
  end
  # Debugging
  unless ENV["CI"]
    if RUBY_VERSION < '1.9'
      s.add_development_dependency('ruby-debug')
    else
      s.add_development_dependency('debugger')
    end
  end
  # Specs
  s.add_development_dependency('rspec-rails', '~> 2.8.0')
  # Fixtures
  s.add_development_dependency('factory_girl', '~> 1.3.2')
  # Population
  s.add_development_dependency('forgery', '~> 0.4.2')
  # Continous integration
  s.add_development_dependency('ci_reporter', '~> 1.6.4')
  # pry
  s.add_development_dependency('pry-rails', '~> 0.2.2')
  # Rails panel
  s.add_development_dependency('meta_request', '~> 0.2.0')
end
