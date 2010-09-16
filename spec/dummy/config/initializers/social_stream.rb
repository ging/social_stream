SocialStream.setup do |config|
  config.actors = [ :user, :space ]

  config.activity_objects = [ :post ]
end
