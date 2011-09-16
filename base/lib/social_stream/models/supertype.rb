require 'active_support/concern'

module SocialStream #:nodoc:
  module Models
    # Common methods for models that have subtypes. Currently, there are two supertypes:
    # * Actor: participates in the social network and has ties with other actors. Its subtypes are subjects, like user or group
    # * ActivityObject: created and managed by actors in activities. Its subtypes are objects, like post or comment
    module Supertype
      extend ActiveSupport::Concern

      included do
        subtypes.each do |s|
          has_one s, :dependent => :destroy
        end
      end

      module ClassMethods
        def subtypes_name
          @subtypes_name
        end

        def subtypes
          SocialStream.__send__ subtypes_name.to_s.tableize # SocialStream.subjects # in Actor
        end
      end 

      module InstanceMethods
        def subtype_instance
          if __send__("#{ self.class.subtypes_name }_type").present?      # if object_type.present?
            object_class = __send__("#{ self.class.subtypes_name }_type") #   object_class = object_type # => "Video"
            __send__ object_class.constantize.base_class.to_s.underscore  #   __send__ "document"
                       end                                                # end
        end
      end
    end
  end
end
