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

  mattr_accessor :resque_access
  @@resque_access = true
 
  mattr_accessor :quick_search_models
  @@quick_search_models = [ :user, :group, :post ]
  
  mattr_accessor :extended_search_models
  @@extended_search_models = [ :user, :group, :post, :comment ]

  mattr_accessor :cleditor_controls
  @@cleditor_controls = "bold italic underline strikethrough subscript superscript | size style | bullets | image link unlink"
 
  class << self
    def setup
      yield self
    end

    def objects
      @@objects.push(:actor) unless @@objects.include?(:actor)
      @@objects
    end

    # Load models for rewrite in application
    #
    # Use this method when you want to reopen some model in SocialStream in order
    # to add or modify functionality
    #
    # Example, in app/models/user.rb
    #   SocialStream.require_model('user')
    #
    #   class User
    #     some_new_functionality
    #   end
    #
    # Maybe Rails provides some method to do this, in this case, please tell!!
    def require_model(m)
      paths = $:.find_all{ |f| f =~ Regexp.new(File.join('social_stream.*', 'app', 'models')) }

      raise "Can't find social_stream path" if paths.blank?

      paths.each do |path|
        if File.exists?(File.join(path, "#{m}.rb"))
          require_dependency File.join(path, m)
        end
      end

    end
  end
end

require 'social_stream/base/engine'
