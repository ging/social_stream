module SocialStream
  module ActivityStreams
    module Subtype
      # The {ActivityStreams}[http://activitystrea.ms/specs/atom/1.0/] object type for
      # this subtype
      def as_object_type
        SocialStream::ActivityStreams.type(self.class)
      end
    end
  end
end
