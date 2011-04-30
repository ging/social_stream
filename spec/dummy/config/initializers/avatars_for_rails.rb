AvatarsForRails.setup do |config|
  config.avatarable_model = :actor
  config.current_avatarable_object = :current_actor
  config.avatarable_filters = [:authenticate_user!]
end