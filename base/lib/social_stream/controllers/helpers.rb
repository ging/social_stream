module SocialStream
  module Controllers
    # Common methods added to ApplicationController
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :current_subject,
                      :profile_subject,
                      :profile_or_current_subject,
                      :profile_subject_is_current?
      end

      module ClassMethods
        # Get the class relative to controller name
        #
        #   Post #=> in PostsController
        #
        def model_class
          controller_name.classify.constantize
        end
      end

      # Current subject represented by the user. Defaults to the own user
      def current_subject
        @current_subject ||=
          current_subject_from_params  ||
          current_subject_from_session ||
            current_user
      end

      # Set represented subject
      def current_subject= instance
        session[:subject_type] = instance.class.to_s
        session[:subject_id]   = instance.id

        @current_subject = instance
      end
        
      def current_actor
        current_subject.actor
      end

      # Returns the {SocialStream::Models::Subject subject} that is in the path, or
      # nil if it is not provided
      #
      #   # /users/demo/posts
      #   profile_subject #=> User demo
      #
      #   # /groups/test/posts
      #   profile_subject #=> Group test
      #
      #   # /posts
      #   profile_subject #=> nil
      #
      #
      def profile_subject
        @profile_subject ||= find_profile_subject
      end

      # Is {#profile_subject} provided?
      def profile_subject?
        profile_subject.present?
      end

      # Raise error if {#profile_subject} is not provided
      def profile_subject!
        profile_subject || warden.authenticate!
      end

      # Returns the {SocialStream::Models::Subject subject} that is in the path, or
      # the {#current_subject} if some {User} is logged in.
      #
      # This method tries {#profile_subject} first and then {#current_subject}
      def profile_or_current_subject
        profile_subject || current_subject
      end

      # This method tries {#profile_or_current_subject} but tries to
      # authenticate if the user is not logged in
      def profile_or_current_subject!
        profile_or_current_subject || warden.authenticate!
      end

      # A {User} must be logged in and is equal to {#profile_subject}
      def profile_subject_is_current?
        user_signed_in? && profile_subject == current_subject
      end

      # Override Cancan#current_ability method to use {#current_subject}
      def current_ability
        @current_ability ||=
          Ability.new(current_subject)
      end

      private

      # Get represented subject from params[:s]
      def current_subject_from_params
        return unless params[:s].present?

        subject = Actor.find_by_slug!(params[:s]).subject

        unless subject.represented_by?(current_user)
          raise CanCan::AccessDenied.new("Not authorized!", :represent, subject.name)
        end

        if subject != current_user
          flash[:notice] ||= ""
          flash[:notice] += t('representation.notice',
                              :subject => subject.name)
        end

        self.current_subject = subject
      end

      # Get represented subject from session
      def current_subject_from_session
        return unless session[:subject_type].present? && session[:subject_id].present?

        session[:subject_type].constantize.find session[:subject_id]
      end

      def find_profile_subject
        SocialStream.subjects.each do |type|
          id = params["#{ type }_id"]

          next if id.blank?

          subject_class = type.to_s.classify.constantize

          return subject_class.find_by_slug! id
        end

        nil
      end
    end
  end
end
