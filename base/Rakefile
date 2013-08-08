# encoding: UTF-8
require 'bundler/gem_tasks'

require 'rdoc/task'

task :default => :rdoc

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SocialStream Base'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb', 'app/**/*.rb')
end

# Modify this gem's tags
class Bundler::GemHelper
  def version_tag
    "base#{version}"
  end
end
