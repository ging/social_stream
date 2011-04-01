class Social2social::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  hook_for :social_stream
  
  source_root File.expand_path('../templates', __FILE__)
  
  def route_pshb
    route "match 'pshb/callback' => 'pshb#callback', :as => :pshb_callback"
  end
  
  def config_initializer
    copy_file 'initializer.rb', 'config/initializers/social2social.rb'
  end
  
end
