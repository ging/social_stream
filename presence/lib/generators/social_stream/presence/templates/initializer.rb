SocialStream::Presence.setup do |config| 
  #Configures XMPP Server Domain
  config.domain = "localhost"
  #Configures Bosh Service Path
  #config.bosh_service = "http://xmpp-proxy/http-bind"
  #Configures Authentication Method: "cookie" or "password"
  config.auth_method = "cookie"
  #Configures XMPP Server Password
  config.xmpp_server_password = "password"
  #Remote or local mode
  config.remote_xmpp_server = false
  #False to disable Social Stream Presence
  #config.enable = false
  
  #Parameters for remote mode
  #Username of the the Social Stream Admin sid
  config.social_stream_presence_username = "social_stream-presence"
  #Configures Social Stream Rails App Password
  config.password = "password"
  
  #Parameters for local mode  
  #Scripts path to execute local ejabberd commands
  config.scripts_path = "/scripts_path"
end