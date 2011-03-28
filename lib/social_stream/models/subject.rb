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
        
        accepts_nested_attributes_for :profile
        
        validates_presence_of :name
        
        scope :alphabetic, joins(:actor).merge(Actor.alphabetic)

        scope :letter, lambda{ |param|
          joins(:actor).merge(Actor.letter(param))
        }

        scope :search, lambda{ |param|
          joins(:actor).merge(Actor.search(param))
        }

        scope :with_sent_ties,     joins(:actor => :sent_ties)
        scope :with_received_ties, joins(:actor => :received_ties)
        scope :distinct_initials, joins(:actor).select('DISTINCT SUBSTR(actors.name,1,1) as initial').order("initial ASC")
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

        # Delegate missing methods to {Actor}, if they are defined there
        def method_missing(method, *args, &block)
          super
        rescue NameError => subject_error 
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
