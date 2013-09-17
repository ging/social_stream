module SocialStream
  module Controllers
    module Objects
      COMMON_PARAMS = [
        :title,
        :description,
        :created_at,
        :updated_at,
        :author_id,
        :owner_id,
        :user_author_id,
        :_activity_parent_id,
        :relation_ids,
        :tag_list
      ]

      extend ActiveSupport::Concern

      included do
        include SocialStream::Controllers::Authorship

        inherit_resources

        before_filter :authenticate_user!, :only => [:new, :edit, :create, :update, :destroy]

        before_filter :set_post_activity, only: :destroy

        after_filter :increment_visit_count, :only => :show

        load_and_authorize_resource :except => [ :new, :index, :search ]

        respond_to :html, :js

        # destroy method must be before the one provided by inherited_resources
        include SocialStream::Controllers::Objects::UpperInstanceMethods
      end

      # Methods that should be included after the included block
      module UpperInstanceMethods
        def search
          collection_variable_set self.class.model_class.search(params[:q], search_options)

          render :layout => false
        end
       
        protected

        def permitted_params
          params.permit(self.class.model_class.to_s.underscore.to_sym => all_allowed_params)
        end

        private

        # Memoize pattern to retrieve objects collection
        def collection
          collection_variable_get ||
            collection_variable_set(build_collection)
        end

        # Uses the {ActivityObject#collection} method to retrieve the objects collection
        def build_collection
          self.class.model_class.                          # @posts = Post.
            collection(profile_subject, current_subject).  #   collection(profile_subject, current_subject).
            page(params[:page])                            #   page(params[:page])
        end
      end

      protected

      def increment_visit_count
        resource.activity_object.increment!(:visit_count) if request.format == 'html'
      end

      def collection_variable_get
        instance_variable_get "@#{ controller_name }"
      end

      def collection_variable_set value
        instance_variable_set "@#{ controller_name }", value
      end

      def activity_object_property_params
        SocialStream.objects.map do |o|
          "add_holder_#{ o }_id".to_sym
        end
      end

      def allowed_params
        [] # This should be overriden in controllers to allow extra params
      end

      def all_allowed_params
        COMMON_PARAMS  |
          activity_object_property_params |
          allowed_params
      end

      def set_post_activity
        @post_activity = resource.post_activity
      end

      private
      
      def search_options
        opts = search_scope_options

        # profile_subject
        if profile_subject.present?
          opts.deep_merge!( { :with => { :owner_id => profile_subject.actor_id } } )
        end

        # Authentication
        opts.deep_merge!({ :with => { :relation_ids => Relation.ids_shared_with(current_subject) } } )

        # Pagination
        opts.merge!({
          :order => :created_at,
          :sort_mode => :desc,
          :per_page => params[:per_page] || self.class.model_class.default_per_page,
          :page => params[:page]
        })

        opts
      end

      def search_scope_options
        if params[:scope].blank? || ! user_signed_in?
          return {}
        end

        case params[:scope]
        when "me"
          { :with => { :author_id => [ current_subject.author_id ] } }
        when "net"
          { :with => { :author_id => current_subject.following_actor_and_self_ids } }
        when "other"
          { :without => { :author_id => current_subject.following_actor_and_self_ids } }
        else
          raise "Unknown search scope #{ params[:scope] }"
        end
      end
    end
  end
end
