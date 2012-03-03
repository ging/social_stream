module SocialStream
  module Events
    module Models
      module Document
        extend ActiveSupport::Concern

        included do
          attr_accessor :event_property_object_id

          before_validation(:on => :create) do
            set_event
          end
        end

        protected

        def set_event
          return if event_property_object_id.blank?

          activity_object_holders <<
            ActivityObjectProperty::Poster.new(:activity_object_id => event_property_object_id)
        end
      end
    end
  end
end
