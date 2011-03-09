class SocialStream::InstallGenerator < Rails::Generators::Base #:nodoc:
  include Rails::Generators::Migration

  hook_for :javascript
  hook_for :authentication

  source_root File.expand_path('../templates', __FILE__)

  def outh_for_devise_config
    inject_into_file "config/initializers/devise.rb",
                     "\n  config.omniauth :linked_in, \"ekxfXU8nueVSMQ9fc5KJAryBkyztUlCBYMW3DoQPzbE79WhivvzhQloRNHCHgPeB\", \"WYiHFT-KKFgjd45W3-pEAficmXRHmN6_6DGwj1C_ZILJlSO1gBvv6VNYXU9tybGY\"
                      \n  config.omniauth :facebook, \"129571360447856\",\"eef39dce5e20e76f77495c59623bdb38\"
                      \n  #config.omniauth :twitter, \"wgTxO0fTpjTeSnjKC9ZHA\",\"JepulVWwLcuAnGfWjwCu47yEP0TcJJfKtvISPBsilI\"",
                      :after => "  # config.omniauth :github, 'APP_ID', 'APP_SECRET', :scope => 'user,public_repo'"
  end

  def create_initializer_file
    copy_file 'initializer.rb', 'config/initializers/social_stream.rb'
  end

  def create_config_relations_file
    copy_file 'relations.yml', 'config/relations.yml'
  end

  def copy_public
    directory "public"
  end

  def remove_public_index
    remove_file 'public/index.html'
  end

  def create_application_layout
    copy_file File.join(File.dirname(__FILE__), '../../../',
                        'app/views/layouts/application.html.erb'),
              'app/views/layouts/application.html.erb'
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
