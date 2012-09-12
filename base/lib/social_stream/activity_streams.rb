module SocialStream
  # Maintains a list of the equivalences between SocialStream's models
  # and ActivityStreams' object types
  #
  # http://activitystrea.ms/specs/json/schema/activity-schema.html#object-types
  module ActivityStreams
    DEFAULT_TYPE = :note

    class << self
      @@register = {}

      # Register a new ActivityStreams type along with the model
      def register(object_type, klass = nil)
        klass ||= object_type

        @@register[object_type] = klass
      end

      # Get the SocialStream's model, given a ActivityStreams' object type
      def model(type)
        model = @@register[type]
        model && model.to_s.classify.constantize
      end

      # Get the SocialStream's model, given a ActivityStreams' object type
      # or the default model
      def model!(type)
        model(type) || model(SocialStream::ActivityStreams::DEFAULT_TYPE)
      end

      # Get the ActivityStreams' object type, given a SocialStream's model
      def type(klass)
        klass = klass.to_s.underscore.to_sym unless klass.is_a?(Symbol)

        @@register.invert[klass]
      end
    end
  end
end
