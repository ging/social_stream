class SocialStream::Documents::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  source_root File.expand_path('../templates', __FILE__)

  def create_migration_file
    require 'rake'
    Rails.application.load_tasks
    Rake::Task['railties:install:migrations'].reenable
    Rake::Task['social_stream_documents_engine:install:migrations'].invoke
  end
end
