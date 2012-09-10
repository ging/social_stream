module SocialStream
  # Maintains a list of the equivalences between SocialStream's models
  # and ActivityStreams' object types
  #
  # http://activitystrea.ms/specs/json/schema/activity-schema.html#object-types
  module ActivityStreams
    class << self
      @@register = {}

      # Register a new ActivityStreams type along with the model
      def register(object_type, klass = nil)
        klass ||= object_type.to_sym

        @@register[object_type] = klass
      end

      # Get the SocialStream's model, given a ActivityStreams' object type
      def model(type)
        @@register[type].to_s.classify.constantize
      end

      # Get the ActivityStreams' object type, given a SocialStream's model
      def type(klass)
        klass = klass.to_s.underscore.to_sym unless klass.is_a?(Symbol)

        @@register.invert[klass]
      end
    end
  end
end
