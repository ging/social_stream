module SocialStream
  module Controllers
    # Common methods added to ApplicationController
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :current_subject
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
            current_subject_from_session ||
              current_user
        end

        # Set represented subject
        def current_subject= instance
          session[:subject_type] = instance.class.to_s
          session[:subject_id]   = instance.id

          @current_subject = instance
        end

        # Override Cancan#current_ability method to use {#current_subject}
        def current_ability
          @current_ability ||=
            Ability.new(current_subject)
        end

        private

        # Get represented subject from session
        def current_subject_from_session
          return unless session[:subject_type].present? && session[:subject_id].present?

          session[:subject_type].constantize.find session[:subject_id]
        end
      end
    end
  end
end
