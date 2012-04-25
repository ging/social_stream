module SocialStream
  module Controllers
    module Objects
      extend ActiveSupport::Concern

      included do
        inherit_resources

        before_filter :set_author_ids, :only => [ :new, :create, :update ]

	after_filter :increment_visit_count, :only => :show

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

        private

        def collection
          collection_variable_get ||
            collection_variable_set(build_collection)
        end

        def build_collection
          collection =
            self.class.model_class # @posts = Post

          # /users/demo/posts
          if profile_subject?
            # get posts posted to demo's wall
            collection = collection.owned_by(profile_subject)

            # if current_subject != demo, auth filter results
            unless profile_subject_is_current?
              collection = collection.shared_with(current_subject)
            end
          else
            # auth filter results
            collection = collection.shared_with(current_subject)

            # if logged in, show the posts from the people following
            if user_signed_in?
              collection = collection.followed_by(current_subject)
            end
          end

          collection = collection.page(params[:page])
        end
      end

      protected

      def increment_visit_count
        resource.activity_object.increment!(:visit_count) if request.format == 'html'
      end

      def set_author_ids
        resource_params.first[:author_id] = current_subject.try(:actor_id)
        resource_params.first[:user_author_id] = current_user.try(:actor_id)
      end

      def collection_variable_get
        instance_variable_get "@#{ controller_name }"
      end

      def collection_variable_set value
        instance_variable_set "@#{ controller_name }", value
      end
    end
  end
end
