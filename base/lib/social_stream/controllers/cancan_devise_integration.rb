module SocialStream
  module Controllers
    # Common methods added to ApplicationController
    module CancanDeviseIntegration
      extend ActiveSupport::Concern
      
      module InstanceMethods

        private

        # Catch some authorization errors:
        #
        # * Redirect to home when the user changes the session and the resource
        #   is not accesible with the new representation
        #
        # * Redirect to login if the user is trying to access a protected resource
        #   and she is not authenticated
        def rescue_from_access_denied(exception)
          if user_signed_in?
            if params[:s].present? && controller_name != 'home'
              redirect_to :home
            else
              raise exception
            end
          else
            redirect_to new_user_session_path
          end
        end
      end
    end
  end
end

