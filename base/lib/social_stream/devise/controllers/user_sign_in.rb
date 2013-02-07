module SocialStream
  module Devise
    module Controllers
      module UserSignIn
        extend ActiveSupport::Concern

        included do
          helpers = %w(resource resource_name resource_class devise_mapping sign_in_controller? )

          hide_action *helpers
          helper_method *helpers
        end

        def resource
          @user
        end

        def resource_name
          :user
        end

        def resource_class
          User
        end

        def devise_mapping
          ::Devise.mappings[:user]
        end

        def sign_in_controller?
          true
        end
      end
    end
  end
end
