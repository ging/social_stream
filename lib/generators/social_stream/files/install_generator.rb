class SocialStream::Files::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  source_root File.expand_path('../templates', __FILE__)
  
  def route_downloads
    route "match 'attachments/:id/:style.:format' => 'attachments#download', :method => 'get'"
    #test
    route "match 'uploadfile/' => 'attachments#new'"
  end
  
  def inject_translations
    copy_file 'en.yml', 'config/locales/files.en.yml'
  end
  
  require 'rails/generators/active_record'

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end

  def create_migration_file
    migration_template 'migration.rb', 'db/migrate/create_social_stream_files.rb'
  end
end
