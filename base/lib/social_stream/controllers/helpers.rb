module SocialStream
  module Controllers
    # Common methods added to ApplicationController
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :current_subject,
                      :profile_subject,
                      :profile_subject_is_current?
      end

      module ClassMethods
        # Add to controllers that have nested subjects. Examples are:
        #
        #   class ProfilesController < InheritedResources::Base
        #     belongs_to_subjects(:singleton => true) # provides /users/demo/profile
        #   end
        #
        #   class ActivitiesController < InheritedResources::Base
        #     belongs_to_subjects # provides /users/demo/activities
        #   end
        #
        def belongs_to_subjects(options = {})
          opts = { :polymorphic => true, :finder => :find_by_slug! }.update(options)

          args = SocialStream.subjects + [ opts ]

          belongs_to *args
        end
      end

      module InstanceMethods
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
        # the {#current_subject} if some {User} is logged in.
        #
        # Requirements: the controller must inherit from +InheritedResources::Base+ and the method
        # {ClassMethods#belongs_to_subjects} must be called
        #
        #   class PostsController < InheritedResources::Base
        #     belongs_to_subjects :optional => true
        #   end
        #
        #   # /users/demo/posts
        #   profile_subject #=> User demo
        #
        #   # /groups/test/posts
        #   profile_subject #=> Group test
        #
        #   # /posts
        #   profile_subject #=> current_subject
        #
        #
        def profile_subject
          @profile_subject ||= association_chain[-1] || current_subject
        end

        # Go to sign in page if {#profile_subject} is blank
        def profile_subject!
          @profile_subject ||= association_chain[-1] || warden.authenticate!
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
      end
    end
  end
end
