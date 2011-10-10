SocialStream.setup do |config|
  # List the models that are social entities. These will have ties between them.
  # Remember you must add an "actor_id" foreign key column to your migration!
  #
  # config.subjects = [:user, :group ]

  # Include devise modules in User. See devise documentation for details.
  # Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable
  # config.devise_modules = :database_authenticatable, :registerable,
  #                         :recoverable, :rememberable, :trackable,
  #                         :omniauthable, :token_authenticatable
  
  # Type of activities managed by actors
  # Remember you must add an "activity_object_id" foreign key column to your migration!
  #
  # config.objects = [ :post, :comment ]
  
  # Form for activity objects to be loaded 
  # You can write your own activity objects
  #
  # config.activity_forms = [ :post, :document, :foo, :bar ]
  
  # Quick search (header) and Extended search models and its order. Remember to create
  # the indexes with thinking-sphinx if you are using customized models.
  # 
  # config.quick_search_models = [:user, :group]
  # config.extended_search_models = [:user, :group]

  # Cleditor controls. It is used in new message editor, for example
  # config.cleditor_controls = "bold italic underline strikethrough subscript superscript | size style | bullets | image link unlink"
end
