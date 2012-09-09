SocialStream::Ostatus.setup do |config|
  # Default to the PubSubHubbub reference Hub server
  # config.hub = 'pubsubhubbub.appspot.com'

  config.node_base_url = 'http://localhost:3000'
end
