class SocialStream::Linkser::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  source_root File.expand_path('../templates', __FILE__)

  def create_migration_file
    require 'rake'
    Rails.application.load_tasks
    Rake::Task['railties:install:migrations'].reenable
    Rake::Task['social_stream_linkser_engine:install:migrations'].invoke
  end

  def require_javascripts
    inject_into_file 'app/assets/javascripts/application.js',
                     "//= require social_stream-linkser\n",
                     :before => '//= require_tree .'
  end

  def require_stylesheets
    append_file 'app/assets/stylesheets/social_stream.css.sass',
                "@import social_stream-linkser\n"
  end
end
