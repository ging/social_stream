Gem::Specification.new do |s|
	s.name = "social_stream-files"
	s.version = "0.0.1"
	s.authors = ["Víctor Sánchez Belmar"]
	s.summary = "Provides capabilities to upload files as another social stream activity"
	s.description = "This gem allow you upload almost any kind of file as new social stream activity."
	s.email = "v.sanchezbelmar@gmail.com"
	s.homepage = "http://github.com/ging/social_stream-files"
	s.files = `git ls-files`.split("\n")

	# Gem dependencies
  s.add_runtime_dependency('social_stream','~> 0.4.4')
  
	# Development Gem dependencies
	s.add_development_dependency('rails', '~> 3.0.7')
	s.add_development_dependency('sqlite3-ruby')
	if RUBY_VERSION < '1.9'
		s.add_development_dependency('ruby-debug', '~> 0.10.3')
	end
	s.add_development_dependency('rspec-rails', '~> 2.5.0')
	s.add_development_dependency('factory_girl', '~> 1.3.2')
	s.add_development_dependency('forgery', '~> 0.3.6')
	s.add_development_dependency('capybara', '~> 0.3.9')
end