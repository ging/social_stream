SocialStream::Ostatus.setup do |config|
  # Default to the PuSH reference Hub server
  #
  # config.hub = 'http://pubsubhubbub.appspot.com'

  # The host where the hub should take the activity feed from
  #
  # Local subjects will publish their public activities there
  config.activity_feed_host = 'localhost:3000'

  # The host where the PuSH should send the callbacks to
  #
  # Remote subjects get their local activities updates with the PuSH callback
  config.pshb_host = 'localhost:3000'

  # Debug OStatus requests
  # config.debug_requests = true
end
