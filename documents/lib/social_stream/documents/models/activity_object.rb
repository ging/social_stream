module SocialStream
  module Documents
    module Models
      module ActivityObject
        extend ActiveSupport::Concern
        extend ::ActivityObject::Properties::HolderMethods

        included do
          property_reflections SocialStream::Documents.subtypes,
                               source: :document,
                               conditions: true
        end

        holder_methods SocialStream::Documents.subtypes
      end
    end
  end
end
