Gem::Specification.new do |s|
  s.name = "social_stream-documents"
  s.version = "0.2.6"
  s.authors = ["Víctor Sánchez Belmar", "GING - DIT - UPM"]
  s.summary = "File capabilities for Social Stream, the core for building social network websites"
  s.description = "Social Stream is a Ruby on Rails engine providing your application with social networking features and activity streams.\n\nThis gem allow you upload almost any kind of file as new social stream activity."
  s.email = "v.sanchezbelmar@gmail.com"
  s.homepage = "http://github.com/ging/social_stream-documents"
  s.files = `git ls-files`.split("\n")

  # Gem dependencies
  s.add_runtime_dependency('social_stream-base','>= 0.9.2')
  s.add_runtime_dependency('paperclip-ffmpeg', '~> 0.7.0')
  s.add_runtime_dependency('paperclip','2.3.11')
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
