class SocialStream::Base::InstallGenerator < Rails::Generators::Base #:nodoc:
  include Rails::Generators::Migration

  hook_for :taggings, :as => :migration
  hook_for :authentication
  hook_for :messages

  source_root File.expand_path(File.join('..', 'templates'), __FILE__)

  def devise_initializer_config
    inject_into_file "config/initializers/devise.rb",
                     "\n  config.omniauth :linked_in, \"ekxfXU8nueVSMQ9fc5KJAryBkyztUlCBYMW3DoQPzbE79WhivvzhQloRNHCHgPeB\", \"WYiHFT-KKFgjd45W3-pEAficmXRHmN6_6DGwj1C_ZILJlSO1gBvv6VNYXU9tybGY\"
                      \n  config.omniauth :facebook, \"129571360447856\",\"eef39dce5e20e76f77495c59623bdb38\"
                      \n  #config.omniauth :twitter, \"wgTxO0fTpjTeSnjKC9ZHA\",\"JepulVWwLcuAnGfWjwCu47yEP0TcJJfKtvISPBsilI\"
                      \n  config.token_authentication_key = :auth_token
                      \n  config.stateless_token = true",
                      :after => "  # config.omniauth :github, 'APP_ID', 'APP_SECRET', :scope => 'user,public_repo'"
  end

  def create_devise_route
    route "devise_for :users, :controllers => {:omniauth_callbacks => 'omniauth_callbacks'}"
  end

  def create_initializer_file
    copy_file 'initializer.rb', 'config/initializers/social_stream.rb'
  end

  def create_config_relations_file
    copy_file 'relations.yml', 'config/relations.yml'
  end

  def remove_public_index
    remove_file 'public/index.html'
  end

  def create_application_layout
    copy_file File.join(File.dirname(__FILE__),
                        '..', '..', '..', '..',
                        'app/views/layouts/application.html.erb'),
              'app/views/layouts/application.html.erb'
  end

  def create_navigation_config
    copy_file 'navigation.rb', 'config/navigation.rb'
  end

  def create_migration_file
    require 'rake'
    Rails.application.load_tasks
    Rake::Task['social_stream_base_engine:install:migrations'].invoke
  end
end
