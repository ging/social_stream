# Gem's dependencies
require 'social_stream/base/dependencies'

# Social Stream's constant declarations
require 'social_stream/base/autoload'

# Provides your Rails application with social network and activity stream support
module SocialStream
  mattr_accessor :subjects
  @@subjects = [ :user, :group, :site ]

  mattr_accessor :devise_modules
  @@devise_modules = [ :database_authenticatable, :registerable, :recoverable,
                       :rememberable, :trackable, :omniauthable, :token_authenticatable]

  mattr_writer :objects
  @@objects = [ :post, :comment ]

  mattr_accessor :activity_forms
  @@activity_forms = []

  mattr_accessor :relation_model
  @@relation_model = :custom

  mattr_accessor :single_relations
  @@single_relations = [ :public, :follow, :reject ]

  mattr_accessor :suggested_models
  @@suggested_models = [ :user, :group ]

  mattr_accessor :contact_index_models
  @@contact_index_models = [ :user, :group ]

  mattr_accessor :repository_models
  @@repository_models = []

  mattr_accessor :resque_access
  @@resque_access = true
 
  mattr_accessor :quick_search_models
  @@quick_search_models = [ :user, :group, :post ]
  
  mattr_accessor :extended_search_models
  @@extended_search_models = [ :user, :group, :post, :comment ]

  mattr_accessor :cleditor_controls
  @@cleditor_controls = "bold italic underline strikethrough subscript superscript | size style | bullets | image link unlink"

  mattr_accessor :default_notification_settings
  @@default_notification_settings = {
      someone_adds_me_as_a_contact: true,
      someone_confirms_my_contact_request: true,
      someone_likes_my_post: true,
      someone_comments_on_my_post: true
  }

  class << self
    def setup
      yield self
    end

    def objects
      @@objects.push(:actor) unless @@objects.include?(:actor)
      @@objects
    end
  end
end

require 'social_stream/base/engine'
