SocialStream.setup do |config|
  ## Subjects

  # List the models that are social entities. These will have ties between them.
  # Remember you must add an "actor_id" foreign key column to your migration!
  #
  # config.subjects = [:user, :group, :site ]
  
  # List of subjects that can be accessed by the client browser or the API
  #
  # config.routed_subjects = [:user, :group, :'site/current' ]

  # Include devise modules in User. See devise documentation for details.
  # Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable
  # config.devise_modules = :database_authenticatable, :registerable,
  #                         :recoverable, :rememberable, :trackable,
  #                         :omniauthable, :token_authenticatable
  
  # Config the default relations that will be created and customized by actors
  # config.custom_relations = {
  #  user: {
  #    friend: {
  #      name: "friend",
  #      permissions: [
  #        [ 'follow' ],
  #        [ 'create',  'activity' ],
  #        [ 'read',    'activity' ]
  #      ]
  #    },
  #  group: {
  #    member: {
  #      name: "member",
  #      permissions: [
  #        [ 'represent' ],
  #        [ 'create', 'activity' ],
  #        [ 'read',   'activity' ],
  #        [ 'read',   'tie' ]
  #      ]
  #    },
  #  'site/current' => {}
  # }

  # Configure the type of actors that are suggested in the sidebar
  #
  # config.suggested_models = [ :user, :group ]
 
  ## Objects

  # Activities objects managed by actors
  # Remember you must add an "activity_object_id" foreign key column to your migration!
  #
  # config.objects += [ :foo, :bar ]

  # Activity objects included in the wall input form
  # You can write your own view in app/views/your_objects/_new_activity.html.erb
  #
  # config.activity_forms = [ :post, :document, :foo, :bar ]
 
  # Objects that appear in the repository tab
  #
  # You must create a vew in app/views/your_objects/_your_object.hmtl.erb
  #
  # config.repository_models = [ :document, :event, :link, :place ]

  # Quick search (header) and Extended search models and its order. Remember to create
  # the indexes with thinking-sphinx and the views at
  # app/views/my_objects/_quick_search_result.html.erb and
  # app/views/my_objects/_search_result.html.erb 
  #
  # config.quick_search_models += [:foo, :bar]
  # config.extended_search_models += [:foo, :bar]
  
  # Expose resque interface to manage background tasks at /resque
  #
  # config.resque_access = true

  # Cleditor controls. It is used in new message editor, for example
  # config.cleditor_controls = "bold italic underline strikethrough subscript superscript | size style | bullets | image link unlink"

  # Default notification email settings for new users
  # config.default_notification_settings = {
  #   someone_adds_me_as_a_contact: true,
  #   someone_confirms_my_contact_request: true,
  #   someone_likes_my_post: true,
  #   someone_comments_on_my_post: true
  # }

end
