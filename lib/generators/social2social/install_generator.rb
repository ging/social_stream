class Social2social::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  hook_for :social_stream
  
  source_root File.expand_path('../templates', __FILE__)
  
  def route_pshb
    route "match 'pshb/callback' => 'pshb#callback', :as => :pshb_callback"
    #route "match 'pshb/test_s' => 'pshb#pshb_subscription_request'"
    #route "match 'pshb/test_p' => 'pshb#pshb_publish'"
  end
  
  def config_initializer
    copy_file 'initializer.rb', 'config/initializers/social2social.rb'
  end
  
end
