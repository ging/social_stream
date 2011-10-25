SocialStream::Presence.setup do |config| 
  #Configures XMPP Server Domain
  config.domain = "localhost"
  #Configures Bosh Service Path
  #config.bosh_service = "http://xmpp-proxy/http-bind"
  #Configures Social Stream Rails App Password
  config.password = "password"
  #Configures XMPP Server Password
  config.xmpp_server_password = "password"
  #Username of the Social Stream Admin sid
  config.social_stream_presence_username = "social_stream-presence"
  #Scripts path, only to execute local ejabberd commands
  config.scripts_path = "/scripts_path"
  #Remote or local mode
  config.remote_xmpp_server = false
  #False to disable Social Stream Presence
  #config.enable = false
end