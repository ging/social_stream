module SocialStream
  module Models
    # {Subject Subjects} are subtypes of {Actor Actors}. {SocialStream Social Stream} provides two
    # {Subject Subjects}, {User} and {Group}
    #
    # Each {Subject} must defined in +config/initializers/social_stream.rb+ in order to be
    # included in the application.
    #
    # = Scopes
    # There are several scopes available for subjects 
    #
    # alphabetic:: sort subjects by name
    # name_search:: simple search by name
    # distinct_initials:: get only the first letter of the name
    # followed:: sort by most following incoming {Tie ties}
    # liked:: sort by most likes
    #
    module Subject
      extend ActiveSupport::Concern

      included do
        subtype_of :actor,
                   :build => { :subject_type => to_s }
        
        has_one :activity_object, :through => :actor
        has_one :profile, :through => :actor
        
        validates_presence_of :name
        
        accepts_nested_attributes_for :profile
        
        scope :alphabetic, joins(:actor).merge(Actor.alphabetic)

        scope :letter, lambda{ |param|
          joins(:actor).merge(Actor.letter(param))
        }

        scope :name_search, lambda{ |param|
          joins(:actor).merge(Actor.name_search(param))
        }
        
        scope :tagged_with, lambda { |param|
          if param.present?
            joins(:actor => :activity_object).merge(ActivityObject.tagged_with(param))
          end
        }

        scope :distinct_initials, joins(:actor).merge(Actor.distinct_initials)

        scope :followed, lambda { 
          joins(:actor).
            merge(Actor.followed)
        }

        scope :liked, lambda { 
          joins(:actor => :activity_object).
            order('activity_objects.like_count DESC')
        }

        scope :most, lambda { |m|
          types = %w( followed liked )

          if types.include?(m)
            __send__ m
          end
        }

        scope :recent, -> {
          order('groups.updated_at DESC')
        }
  
        define_index do
          indexes actor.name, :sortable => true
          indexes actor.email
          indexes actor.slug
                
          has created_at
          has Relation::Public.instance.id.to_s, :type => :integer, :as => :relation_ids
          
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

        # The types of actors that appear in the contacts/index
        #
        # You can customize this in each class
        def contact_index_models
          SocialStream.contact_index_models
        end
      end

      def to_param
        slug
      end
    end
  end
end
