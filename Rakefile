# encoding: UTF-8
require 'rake'
require 'rake/rdoctask'
require 'rake/gempackagetask'

require 'rspec/core'
require 'rspec/core/rake_task'

require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'version')


Rspec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--color"]
end

task :default => :spec

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SocialStream'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb', 'app/**/*.rb')
end

spec = Gem::Specification.new do |s|
  s.name = "social_stream"
  s.version = SocialStream::VERSION.dup
  s.summary = "Social networking features and activity streams for Ruby on Rails."
  s.description = "Ruby on Rails engine supporting social networking features and activity streams."
  s.authors = ['Antonio Tapiador', 'Diego Carrera']
  s.files =  FileList["[A-Z]*", "{app,config,lib}/**/*"]
  s.add_dependency('atd-ancestry', '~> 1.3.0')
  s.add_dependency('devise', '~> 1.1.3')
  s.add_dependency('inherited_resources', '~> 1.1.2')
end

Rake::GemPackageTask.new(spec) do |pkg|
end

desc "Install the gem #{spec.name}-#{spec.version}.gem"
task :install => :gem do
  system("sudo gem install pkg/#{spec.name}-#{spec.version}.gem --no-ri --no-rdoc")
end
