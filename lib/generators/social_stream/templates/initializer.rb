SocialStream.setup do |config|
  # List the models that are social entities. These will have ties between them.
  #
  # Remember you must add an "actor_id" foreign key column to your migration!
  #
  # Example: config.actors = [ :user ]
  config.actors = []

  # Contents managed by actors
  #
  # Remember you must add an "activity_object_id" foreign key column to your migration!
  #
  # Example: config.activity_objects = [ :post, :comment, :photo ]
  config.activity_objects = []
end
