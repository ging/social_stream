SocialStream::Ostatus.setup do |config|
  config.hub = 'http://localhost:4567/'
  config.node_base_url = 'http://localhost:3000'
end
