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
        def subtypes
          SocialStream.__send__ @subtypes_name.to_s.tableize # SocialStream.subjects # in Actor
        end

        def load_subtype_features
          features = "SocialStream::Models::#{ @subtypes_name.to_s.classify }".constantize

          subtypes.each do |s|
            s = s.to_s.classify.constantize
            s.__send__(:include, features) unless s.ancestors.include?(features)
          end
        end
      end 

      module InstanceMethods
        def subtype_instance
          self.class.subtypes.each do |s|
            i = __send__(s)
            return i if i.present?
          end

          nil
        end
      end
    end
  end
end
