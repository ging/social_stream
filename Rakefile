# encoding: UTF-8
require 'rake'
require 'rake/rdoctask'

require 'rubygems'

require 'rspec/core'
require 'rspec/core/rake_task'

require 'bundler'

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

class Bundler::GemHelper
  def install_gem
    built_gem_path = build_gem
    out, err, code = sh_with_code("sudo gem install #{built_gem_path} --no-rdoc --no-ri")
    if err[/ERROR/]
      Bundler.ui.error err
    else
      Bundler.ui.confirm "#{name} (#{version}) installed"
    end
  end
end

Bundler::GemHelper.install_tasks
