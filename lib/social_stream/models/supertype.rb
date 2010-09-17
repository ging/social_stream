require 'active_support/concern'

module SocialStream #:nodoc:
  module Models
    module Supertype
      extend ActiveSupport::Concern

      included do
        subtypes.each do |s|
          has_one s, :dependent => :destroy
        end
      end

      module ClassMethods
        def subtypes
          SocialStream.__send__ to_s.tableize
        end

        def load_subtype_features
          features = "SocialStream::Models::#{ to_s }".constantize

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
