class SocialStream::InstallGenerator < Rails::Generators::Base #:nodoc:
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  def create_initializer_file
    copy_file 'initializer.rb', 'config/initializers/social_stream.rb'
  end

  def create_config_file
    copy_file 'seeds.yml', 'db/seeds/social_stream.yml'
  end

  # TODO: hook_for :orm
  require 'rails/generators/active_record'

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end

  def create_migration_file
    migration_template 'migration.rb', 'db/migrate/create_social_stream.rb'
  end

end
