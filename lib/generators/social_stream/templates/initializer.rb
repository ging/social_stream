SocialStream.setup do |config|
  # List the models that are social entities. These will have ties between them.
  # Remember you must add an "actor_id" foreign key column to your migration!
  #
  # config.subjects = [:user, :group ]

  # Include devise modules in User. See devise documentation for details.
  # Others available are:
  # :token_authenticatable, :confirmable, :lockable, :timeoutable, :validatable
  # config.devise_modules :database_authenticatable, :registerable,
  #                       :recoverable, :rememberable, :trackable, :omniauthable
  
  # Type of activities managed by actors
  # Remember you must add an "activity_object_id" foreign key column to your migration!
  #
  # config.objects = [ :post, :comment ]
end
