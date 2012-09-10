module SocialStream
  module ActivityStreams
    module Supertype
      # The {ActivityStreams}[http://activitystrea.ms/specs/atom/1.0/] object type for
      # this object
      def as_object_type
        subtype_instance.as_object_type
      end

    end
  end
end
