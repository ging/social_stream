module ActiveRecord #:nodoc:
  module Supertype
    extend ActiveSupport::Concern

    module ClassMethods
      def subtypes
        @subtypes ||= []
      end

      def subtype(klass)
        klass_sym = klass.to_s.underscore.to_sym

        @subtypes = subtypes | Array(klass_sym)

        class_eval do
          has_one klass_sym, :dependent => :destroy
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
