class SocialstreamFiles::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  def route_downloads
    route "match 'attachments/:id/:style.:format' => 'attachments#download'"
  end
  
  require 'rails/generators/active_record'

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end

  def create_migration_file
    migration_template 'migration.rb', 'db/migrate/create_social_stream_files.rb'
  end
end
