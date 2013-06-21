class SocialStream::Base::InstallGenerator < Rails::Generators::Base #:nodoc:
  include Rails::Generators::Migration

  hook_for :taggings, :as => :migration
  hook_for :authentication
  hook_for :messages

  source_root File.expand_path(File.join('..', 'templates'), __FILE__)

  def devise_initializer_config
    inject_into_file "config/initializers/devise.rb",
                     "  config.omniauth :socialstream, \"4\",\"00053446bc0361d60889b734d9e5f6132cccf3d08abb25a39bc79e23edde80d5900c37ec69aa0aaf7f969bb046858429ffb318de789b553b03ed672ff75859ab\"
                      \n  config.token_authentication_key = :auth_token
                      \n  config.skip_session_storage << :token_auth",
                      :after => "  # config.omniauth :github, 'APP_ID', 'APP_SECRET', :scope => 'user,public_repo'"
  end

  def create_devise_route
    route "devise_for :users, :controllers => {:omniauth_callbacks => 'omniauth_callbacks'}"
  end

  def create_initializer_file
    copy_file 'initializer.rb', 'config/initializers/social_stream.rb'
  end

  def create_config_sphinx_file
    copy_file 'sphinx.yml', 'config/sphinx.yml'
  end

  def remove_public_index
    remove_file 'public/index.html'
  end

  def remove_application_layout
    remove_file 'app/views/layouts/application.html.erb'
  end

  def require_javascripts
    inject_into_file 'app/assets/javascripts/application.js',
                     "//= require social_stream-base\n",
                     :before => '//= require_tree .'
  end

  def require_stylesheets
    inject_into_file 'app/assets/stylesheets/application.css',
                     " *= require social_stream\n",
                     :before => ' *= require_tree .'
  end

  def create_sass_stylesheets_file
    copy_file 'social_stream.css.sass', 'app/assets/stylesheets/social_stream.css.sass'
  end

  def create_migration_file
    require 'rake'
    Rails.application.load_tasks
    Rake::Task['railties:install:migrations'].reenable
    Rake::Task['social_stream_base_engine:install:migrations'].invoke
  end

  def create_ability_file
    ability_code = [
      "# Generator social_stream:install has modified this file. Please,",   #0
      "# check everything is working ok, specially if the former `Ability`", #1
      "# class inherited from another class or included another module",     #2
      "class Ability",                                                       #3
      "  include SocialStream::Ability",                                     #4
      "",                                                                    #5
      "  def initialize(subject)",                                           #6
      "    super",                                                           #7
      "",                                                                    #8
      "    # Add your authorization rules here",                             #9
      "    # For instance:",                                                 #10
      "    #    can :create, Comment",                                       #11
      "    #    can [:create, :destroy], Post do |p|",                       #12
      "    #      p.actor_id == Actor.normalize_id(subject)",                #13
      "    #    end",                                                        #14
      "  end",                                                               #15
      "end"]                                                                 #16
    ability_file = 'app/models/ability.rb'

    if FileTest.exists? ability_file
      prepend_to_file ability_file, ability_code[0..2].join("\n")+"\n"
      if not File.read(ability_file).include?("include SocialStream::Ability\n")
        inject_into_file ability_file, ability_code[4..5].join("\n")+"\n", :after => /class Ability(.*)\n/
      end
      if File.read(ability_file).include?("def initialize\n")
        inject_into_file ability_file, ability_code[7..14].join("\n")+"\n", :after => /def initialize(.*)\n/
      else
        inject_into_file ability_file, ability_code[5..15].join("\n")+"\n", :after => /include SocialStream::Ability\n/
      end
    else
      create_file ability_file, ability_code[3..16].join("\n")
    end
  end
end
