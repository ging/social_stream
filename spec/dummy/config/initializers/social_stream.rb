SocialStream.setup do |config|
  config.actors = [ :user, :group ]

  config.activity_objects = [ :post, :comment ]
end
