# Provides your Rails application with social network and activity stream support
module SocialStream
  autoload :Ability,   'social_stream/ability'
  autoload :Populate,  'social_stream/populate'
  autoload :Relations, 'social_stream/relations'
  autoload :TestHelpers, 'social_stream/test_helpers'

  module Controllers
    autoload :Helpers, 'social_stream/controllers/helpers'
  end

  module Models
    autoload :Supertype, 'social_stream/models/supertype'
    autoload :Subject,   'social_stream/models/subject'
    autoload :Object,    'social_stream/models/object'
  end

  module TestHelpers
    autoload :Controllers, 'social_stream/test_helpers/controllers'
  end

  mattr_accessor :subjects
  @@subjects = [ :user, :group ]

  mattr_accessor :devise_modules
  @@devise_modules = [ :database_authenticatable, :registerable, :recoverable,
                       :rememberable, :trackable, :omniauthable, :token_authenticatable]

  mattr_writer :objects
  @@objects = [ :post, :comment ]

  class << self
    def setup
      yield self
    end

    def objects
      @@objects | [ :actor ]
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
      path = $:.find{ |f| f =~ Regexp.new(File.join('social_stream.*', 'app', 'models')) }

      raise "Can't find social_stream path" if path.blank?

      require_dependency File.join(path, m)
    end
  end
end

require 'social_stream/rails'
