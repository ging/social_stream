module SocialStream
  module Controllers
    module Subjects
      extend ActiveSupport::Concern

      included do
        inherit_resources

        protected

        # Overwrite resource method to support slug
        # See InheritedResources::BaseHelpers#resource
        def method_for_find
          :find_by_slug!
        end
      end

      # Overwrite {SocialStream::Controllers::Helpers::InstanceMethods#profile_subject}
      def profile_subject
        self.class.model_class.find_by_slug(params[:id])
      end

    end
  end
end

