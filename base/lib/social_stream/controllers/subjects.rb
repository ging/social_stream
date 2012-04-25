module SocialStream
  module Controllers
    module Subjects
      extend ActiveSupport::Concern

      included do
        include SocialStream::Controllers::Helpers

        inherit_resources
      end

      # Overwrite {SocialStream::Controllers::Helpers::InstanceMethods#profile_subject}
      def profile_subject
        self.class.model_class.find_by_slug(params[:id])
      end
    end
  end
end

