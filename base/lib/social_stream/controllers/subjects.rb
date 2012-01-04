module SocialStream
  module Controllers
    module Subjects
      extend ActiveSupport::Concern

      included do
        inherit_resources
      end

      module InstanceMethods
        # Overwrite {SocialStream::Controllers::Helpers::InstanceMethods#profile_subject}
        def profile_subject
          resource
        end
      end
    end
  end
end

