module SocialStream
  module Places
    module Models
      module Document
        extend ActiveSupport::Concern

        included do
          attr_accessor :place_property_object_id

          before_validation(:on => :create) do
            set_place
          end
        end

        protected

        def set_place
          return if place_property_object_id.blank?

          activity_object_holders <<
            ActivityObjectProperty::Poster.new(:activity_object_id => place_property_object_id)
        end
      end
    end
  end
end
