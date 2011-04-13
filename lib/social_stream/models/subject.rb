require 'active_support/concern'

module SocialStream
  module Models
    # {Subject Subjects} are subtypes of {Actor}. {SocialStream} provides two
    # {Subject Subjects}, {User} and {Group}
    #
    # Each {Subject} is defined in +config/initializers/social_stream.rb+
    #
    # This module provides additional features for models that are subjects,
    # extending them. Including the module in each {Subject} model is not required!
    # After declared in +config/initializers/social_stream.rb+, {SocialStream} is
    # responsible for adding subject features to each model.
    #
    # = Scopes
    # There are several scopes available for subjects 
    #
    # alphabetic:: sort subjects by name
    # search:: simple search by name
    # distinct_initials:: get only the first letter of the name
    # popular:: sort by most incoming {Tie ties}
    #
    module Subject
      extend ActiveSupport::Concern
      
      included do
        belongs_to :actor,
                   :validate => true,
                   :autosave => true
        
        has_one :profile, :through => :actor
        
        validates_presence_of :name
        
        accepts_nested_attributes_for :profile
        
        scope :alphabetic, joins(:actor).merge(Actor.alphabetic)

        scope :letter, lambda{ |param|
          joins(:actor).merge(Actor.letter(param))
        }

        scope :search, lambda{ |param|
          joins(:actor).merge(Actor.search(param))
        }
        
        scope :tagged_with, lambda { |param|
          if param.present?
            joins(:actor => :activity_object).merge(ActivityObject.tagged_with(param))
          end
        }

        scope :distinct_initials, joins(:actor).merge(Actor.distinct_initials)

        scope :popular, lambda { 
          joins(:actor => :received_ties).
            select("DISTINCT #{ table_name }.*, COUNT(#{ table_name}.id) AS popularity").
            group("#{ table_name }.id").
            order("popularity DESC")
        }
      end
      
      module InstanceMethods
        def actor!
          actor || build_actor(:subject_type => self.class.to_s)
        end
        
        def to_param
          slug
        end

        # Delegate missing methods to {Actor}, if they exist there
        def method_missing(method, *args, &block)
          super
        rescue NameError => subject_error 
          # These methods must be raised to avoid loops (the :actor association calls here again)
          exceptions = [ :_actor_id ]
          raise subject_error if exceptions.include?(method)

          actor!.__send__ method, *args, &block
        end

        # {Actor} handles some methods
        def respond_to? *args
          super || actor!.respond_to?(*args)
        end
      end
      
      module ClassMethods
        def find_by_slug(perm)
          includes(:actor).where('actors.slug' => perm).first
        end
        
        def find_by_slug!(perm)
          find_by_slug(perm) ||
            raise(ActiveRecord::RecordNotFound)
        end 
      end
    end
  end
end
