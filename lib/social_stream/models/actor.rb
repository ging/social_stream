require 'active_support/concern'

module SocialStream
  module Models
    # Additional features for models that are subtypes of actors
    module Actor
      extend ActiveSupport::Concern

      included do
        belongs_to :actor,
                   :validate => true,
                   :autosave => true

        delegate :name, :name=,
                 :email, :email=,
                 :permalink, :permalink=,
                 :disabled, :disabled=,
                 :ties, :sent_ties, :received_ties,
                 :sender_subjects, :receiver_subjects, :suggestion,
                 :wall,
                 :to => :actor!


        scope :with_sent_ties,     joins(:actor => :sent_ties)
        scope :with_received_ties, joins(:actor => :received_ties)

        after_create :initialize_default_ties
      end

      module InstanceMethods
        def actor!
          actor || build_actor
        end

        private

        def initialize_default_ties
          self.class.relations.where(:default => true).each do |r|
            Tie.create! :sender => self.actor,
                        :receiver => self.actor,
                        :relation => r
          end
        end
      end

      module ClassMethods
        # Relations defined for this actor model.
        def relations(to = to_s)
          Relation.mode(to_s, to)
        end

        # Actor subtypes that may receive a tie from an instance of this class
        def receiving_subject_classes
          Relation.select("DISTINCT #{ Relation.quoted_table_name }.receiver_type").
            where(:sender_type => to_s).
            map(&:receiver_type).
            map(&:constantize)
        end
      end
    end
  end
end
