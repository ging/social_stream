# encoding: UTF-8
require 'rake'
require 'rake/rdoctask'

require 'rubygems'

require 'rspec/core/rake_task'

require 'ci/reporter/rake/rspec'

require 'bundler'

require File.join(File.dirname(__FILE__), 'lib', 'social_stream', 'version')


RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SocialStream'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb', 'app/**/*.rb')
end

Bundler::GemHelper.install_tasks
