require 'active_support/concern'

module SocialStream
  module Models
    # Additional features for models that are subtypes of actors, like User or Group
    module Subject
      extend ActiveSupport::Concern

      included do
        belongs_to :actor,
                   :validate => true,
                   :autosave => true

        delegate :name, :name=,
                 :email, :email=,
                 :permalink,
                 :logo, :logo=,
                 :ties, :sent_ties, :received_ties,
                 :ties_to,
                 :sent_ties_allowing,
                 :pending_ties,
                 :relation, :relations,
                 :actors, :subjects,
                 :suggestions, :suggestion,
                 :home_wall, :profile_wall,
                 :to => :actor!

        has_one :profile, :through => :actor

        accepts_nested_attributes_for :profile

        validates_presence_of :name

        scope :alphabetic, includes(:actor).order('actors.name')

        scope :with_sent_ties,     joins(:actor => :sent_ties)
        scope :with_received_ties, joins(:actor => :received_ties)
      end

      module InstanceMethods
        def actor!
          actor || build_actor(:subject_type => self.class.to_s)
        end

        def to_param
          permalink
        end
      end

      module ClassMethods
        def find_by_permalink(perm)
          joins(:actor).where('actors.permalink' => perm).first
        end

        def find_by_permalink!(perm)
          find_by_permalink(perm) ||
            raise(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
