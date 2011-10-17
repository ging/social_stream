class SocialStream::Presence::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  source_root File.expand_path('../templates', __FILE__)

  def create_initializer_file
    copy_file 'initializer.rb', 'config/initializers/social_stream-presence.rb'
  end

  def create_migration_file
    require 'rake'
    Rails.application.load_tasks
    Rake::Task['railties:install:migrations'].reenable
    Rake::Task['social_stream_presence_engine:install:migrations'].invoke
  end

  def require_javascripts
    inject_into_file 'app/assets/javascripts/application.js',
                     "//= require social_stream-presence\n",
                     :before => '//= require_tree .'
  end

  def require_stylesheets
    inject_into_file 'app/assets/stylesheets/application.css',
                     " *= require social_stream-presence\n",
                     :before => ' *= require_tree .'
  end
end
