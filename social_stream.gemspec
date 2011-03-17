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
  s.add_runtime_dependency('atd-ancestry', '1.3.0')
  s.add_runtime_dependency('nested_set', '~> 1.5.3')
  s.add_runtime_dependency('foreigner', '~> 0.9.1')
  s.add_runtime_dependency('devise', '~> 1.2.rc')
  s.add_runtime_dependency('inherited_resources', '~> 1.1.2')
  s.add_runtime_dependency('stringex', '~> 1.2.0')
  s.add_runtime_dependency('paperclip', '~> 2.3.4')
  s.add_runtime_dependency('jquery-rails', '~> 0.2.5')
  s.add_runtime_dependency('cancan', '~> 1.5.1')
  s.add_runtime_dependency('will_paginate', '~> 3.0.pre2')
  s.add_runtime_dependency('omniauth','~> 0.2.0.beta5')	
  s.add_runtime_dependency('oauth-plugin','~> 0.4.0.pre1')	
  s.add_runtime_dependency('rails_css_themes','~> 1.0.0')	
  s.add_development_dependency('rails', '~> 3.0.5')
  s.add_development_dependency('capybara', '~> 0.3.9')
  s.add_development_dependency('sqlite3-ruby')
  if RUBY_VERSION < '1.9'
    s.add_development_dependency('ruby-debug', '~> 0.10.3')
  end
  s.add_development_dependency('rspec-rails', '~> 2.5.0')
  s.add_development_dependency('factory_girl', '~> 1.3.2')
  s.add_development_dependency('forgery', '~> 0.3.6')
  s.add_development_dependency('ci_reporter', '~> 1.6.4')
  s.add_development_dependency('nifty-generators','~> 0.4.5')
  
  #mailboxer  
  s.add_runtime_dependency('mailboxer','~> 0.0.7')
end
