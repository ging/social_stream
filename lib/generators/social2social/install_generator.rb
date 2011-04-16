class Social2social::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  hook_for :social_stream
  
  source_root File.expand_path('../templates', __FILE__)
  
  def route_pshb
    route "match 'pshb/callback' => 'pshb#callback', :as => :pshb_callback"
  end
  
  def route_ru
    route "match 'remoteuser/' => 'remoteusers#index', :as => :add_remote_user"
  end
  
  def config_initializer
    copy_file 'initializer.rb', 'config/initializers/social2social.rb'
  end
  
  def inject_remote_user_relation
    append_file 'config/relations.yml',
                     "\nremote_user:\n  friend:\n    name: friend\n    permissions:\n      - [ follow ]\n"+
                                     "  public:\n    name: public\n    permissions:\n      - [ read, tie, star_tie ]"  
  end
  
  require 'rails/generators/active_record'

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end

  def create_migration_file
    migration_template 'migration.rb', 'db/migrate/create_social2social.rb'
  end
  
end
