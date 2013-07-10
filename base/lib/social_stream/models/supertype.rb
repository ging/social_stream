module SocialStream #:nodoc:
  module Models
    # Common methods for models having many {SocialStream::Models::Subtype subtypes}.
    # Currently, there are two {SocialStream::Models::Supertype supertypes}:
    # * {Actor}: participates in the social network and has {Tie Ties} with other actors.
    #   Its subtypes are {SocialStream::Models::Subject subjects}, such as {User} or {Group}
    # * {ActivityObject}: created and managed by {Actor Actors} in {Activity Activities}.
    #   Its subtypes are {SocialStream::Models::Object objects}, like {Post} or {Comment}
    #
    # Methods are documented for the case of {Actor} supertype
    module Supertype
      extend ActiveSupport::Concern

      include SocialStream::ActivityStreams::Supertype

      included do
        subtypes.each do |s|                          # [ :user, :group ].each do |s|
          has_one s,                                  #   has_one s,
                  autosave:   false,                  #           autosave:   false,
                  inverse_of: name.underscore.to_sym  #           inverse_of: :actor
        end                                           # end
      end

      module ClassMethods
        def subtypes_name # :subject
          @subtypes_name
        end

        def subtypes
          SocialStream.__send__ subtypes_name.to_s.tableize # SocialStream.subjects # => [:user, :group ]
        end

        # Get the supertype id from an object, if possible
        def normalize_id(a)
          case a
          when Integer
            a
          when String
            a.to_i
          when Array
            a.map{ |e| normalize_id(e) }
          else
            normalize(a).id
          end
        end

        # Get supertype from object, if possible
        def normalize(a)
          case a
          when self
            a
          when Integer
            find a
          when Array
            a.map{ |e| normalize(e) }
          else
            begin
              a.__send__ "#{ name.underscore }!" # a.actor!
            rescue
              raise "Unable to normalize #{ self } #{ a.inspect }"
            end
          end
        end
      end 

      def subtype_instance
        if __send__("#{ self.class.subtypes_name }_type").present?      # if object_type.present?
          object_class = __send__("#{ self.class.subtypes_name }_type") #   object_class = object_type # => "Video"
          __send__ object_class.constantize.base_class.to_s.underscore  #   __send__ "document"
                     end                                                # end
      end

      # Include the class method {#supertype_of} to ActiveRecord::Base
      module ActiveRecord
        extend ActiveSupport::Concern

        module ClassMethods
          # This class is a supertype. Subtype classes are known as name
          def supertype_of name
            @subtypes_name = name
            include SocialStream::Models::Supertype
          end
        end
      end
    end
  end
end
