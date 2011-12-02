module SocialStream
  module Controllers
    module Objects
      extend ActiveSupport::Concern

      included do
        inherit_resources

        before_filter :set_author_ids, :only => [ :new, :create, :update ]

        load_and_authorize_resource :except => :index

        respond_to :html, :js

        # destroy method must be before the one provided by inherited_resources
        include SocialStream::Controllers::Objects::UpperInstanceMethods
      end

      # Methods that should be included after the included block
      module UpperInstanceMethods
        def destroy
          @post_activity = resource.post_activity

          destroy!
        end
      end

      module InstanceMethods

        protected

        def set_author_ids
          resource_params.first[:author_id] = current_subject.try(:actor_id)
          resource_params.first[:user_author_id] = current_user.try(:actor_id)
        end
      end
    end
  end
end
