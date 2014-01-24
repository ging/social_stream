# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'documents', 'version')

Gem::Specification.new do |s|
  s.name = "social_stream-documents"
  s.version = SocialStream::Documents::VERSION.dup
  s.authors = ["Víctor Sánchez Belmar", "GING - DIT - UPM"]
  s.summary = "File capabilities for Social Stream, the core for building social network websites"
  s.description = "Social Stream is a Ruby on Rails engine providing your application with social networking features and activity streams.\n\nThis gem allow you upload almost any kind of file as new social stream activity."
  s.email = "social-stream@dit.upm.es"
  s.homepage = "http://github.com/ging/social_stream-documents"
  s.files = `git ls-files`.split("\n")
  s.license = 'MIT'

  # Gem dependencies
  s.add_runtime_dependency('social_stream-base', '~> 2.2.2')

  s.add_runtime_dependency('paperclip','~> 3.5.1')
  s.add_runtime_dependency('paperclip-ffmpeg', '~> 1.0.1')
  s.add_runtime_dependency('delayed_paperclip','>= 2.6.1')
end
