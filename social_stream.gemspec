require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream"
  s.version = SocialStream::VERSION.dup
  s.summary = "Social networking features and activity streams for Ruby on Rails."
  s.description = "Ruby on Rails engine supporting social networking features and activity streams."
  s.authors = ['Antonio Tapiador', 'Diego Carrera']
  s.files = `git ls-files`.split("\n")
  s.add_dependency('atd-ancestry', '~> 1.3.0')
  s.add_dependency('devise', '~> 1.1.3')
  s.add_dependency('inherited_resources', '~> 1.1.2')
  s.add_dependency('stringex', '~> 1.2.0')
  s.add_dependency('paperclip', '~> 2.3.4')
end
