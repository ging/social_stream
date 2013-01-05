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
  # Be sure to add the other modules of Social Stream you might be using (e.g. :document, :event, :link ).
  #
  # config.objects = [ :post, :comment ]

  # Form for activity objects to be loaded
  # You can write your own activity objects
  #
  # config.activity_forms = [ :post, :document, :foo, :bar ]

  # Config the relation model of your network
  #
  # :custom - users define their own relation types, and post with privacy, like Google+
  # :follow - user just follow other users, like Twitter
  #
  # config.relation_model = :custom

  # Expose resque interface to manage background tasks at /resque
  #
  # config.resque_access = true

  # Quick search (header) and Extended search models and its order. Remember to create
  # the indexes with thinking-sphinx if you are using customized models.
  #
  # config.quick_search_models = [:user, :group]
  # config.extended_search_models = [:user, :group]

  # Cleditor controls. It is used in new message editor, for example
  # config.cleditor_controls = "bold italic underline strikethrough subscript superscript | size style | bullets | image link unlink"
  
  # auto read notifications
  # config.auto_read_notification = false
end

# You can customize toolbar, sidebar and location bar from here
# See https://github.com/ging/social_stream/wiki/How-to-customize-the-toolbar,-sidebar-and-location
