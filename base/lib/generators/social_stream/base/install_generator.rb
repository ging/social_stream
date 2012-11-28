class SocialStream::Base::InstallGenerator < Rails::Generators::Base #:nodoc:
  include Rails::Generators::Migration

  hook_for :taggings, :as => :migration
  hook_for :authentication
  hook_for :messages

  source_root File.expand_path(File.join('..', 'templates'), __FILE__)

  def devise_initializer_config
    inject_into_file "config/initializers/devise.rb",
                     "\n  config.omniauth :linkedin, \"ekxfXU8nueVSMQ9fc5KJAryBkyztUlCBYMW3DoQPzbE79WhivvzhQloRNHCHgPeB\", \"WYiHFT-KKFgjd45W3-pEAficmXRHmN6_6DGwj1C_ZILJlSO1gBvv6VNYXU9tybGY\"
                      \n  config.omniauth :facebook, \"129571360447856\",\"eef39dce5e20e76f77495c59623bdb38\"
                      \n  #config.omniauth :twitter, \"wgTxO0fTpjTeSnjKC9ZHA\",\"JepulVWwLcuAnGfWjwCu47yEP0TcJJfKtvISPBsilI\"
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

  def create_config_relations_file
    copy_file 'relations.yml', 'config/relations.yml'
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
                     " *= require social_stream-base\n",
                     :before => ' *= require_tree .'
  end

  def create_migration_file
    require 'rake'
    Rails.application.load_tasks
    Rake::Task['railties:install:migrations'].reenable
    Rake::Task['social_stream_base_engine:install:migrations'].invoke
  end

  def create_ability_file
    ability_code = [
      "class Ability",                                            #0
      "  include SocialStream::Ability",                          #1
      "",                                                         #2
      "  def initialize(subject)",                                #3
      "    super",                                                #4
      "",                                                         #5
      "    # Add your authorization rules here",                  #6
      "    # For instance:",                                      #7
      "    #    can :create, Comment",                            #8
      "    #    can [:create, :destroy], Post do |p|",            #9
      "    #      p.actor_id == Actor.normalize_id(subject)",     #10
      "    #    end",                                             #11
      "  end",                                                    #12
      "end"]                                                      #13
    ability_file = 'app/models/ability.rb'

    if FileTest.exists? ability_file
      code = RubyParser.new.parse File.read ability_file

      ability_class = nil
      if (code.sexp_type == :class)
        if (code.sexp_body.first.to_s == 'Ability')
          ability_class = code
        end
      else
        code.each_of_type(:class) do |klass|
          if klass.sexp_body.first == 'Ability'
            ability_class = klass
          end
        end
      end
      if ability_class
        include_found = false
        initialize_found = false
        super_found = false
        code.each_of_type(:defn) do |method|
          if method.sexp_body.first.to_s == "initialize"
            initialize_found = true
            method.each_of_type(:zsuper) { super_found = true }
          end
        end
        if not File.read(ability_file).include?("include SocialStream::Ability\n")
          inject_into_file ability_file, ability_code[1..2].join("\n")+"\n", :after => /class Ability(.*)\n/
        end
        if initialize_found
          if super_found
            inject_into_file ability_file, ability_code[6..11].join("\n")+"\n", :after => /def initialize(.*)\n/
          else
            inject_into_file ability_file, ability_code[4..11].join("\n")+"\n", :after => /def initialize(.*)\n/
          end
        else
          inject_into_file ability_file, ability_code[2..12].join("\n")+"\n", :after => /include SocialStream::Ability\n/
        end
      else
        # ability.rb without Ability class. Should we raise an exception?
        append_to_file ability_file, ability_code.join("\n")
      end
    else
      create_file ability_file, ability_code.join("\n")
    end
    # Does not work correctly when the old Ability class inherits from a class
    # or includes a module whose 'initialize' method is non-empty and does not
    # call 'super'
  end
end
