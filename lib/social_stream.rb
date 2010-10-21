# Provides your Rails application with social network and activity stream support
module SocialStream
  autoload :Seed, 'social_stream/seed'

  module Models
    autoload :Supertype, 'social_stream/models/supertype'
    autoload :Actor, 'social_stream/models/actor'
    autoload :ActivityObject, 'social_stream/models/activity_object'
  end

  mattr_accessor :actors
  @@actors = [ :user, :group ]

  mattr_accessor :devise_modules
  @@devise_modules = [ :database_authenticatable, :registerable, :recoverable,
                       :rememberable, :trackable ]

  mattr_accessor :activity_objects
  @@activity_objects = [ :post, :comment ]

  class << self
    def setup
      yield self
    end

    def seed!
      Seed.new(File.join(::Rails.root, 'db', 'seeds', 'social_stream.yml'))
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
      path = $:.find{ |f| f =~ Regexp.new(File.join('social_stream', 'app', 'models')) }

      raise "Can't find social_stream path" if path.blank?

      require_dependency File.join(path, m)
    end
  end
end

require 'social_stream/rails'
