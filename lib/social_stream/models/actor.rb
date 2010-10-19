require 'active_support/concern'

module SocialStream
  module Models
    # Additional features for models that are actors
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
                 :contacts, :suggestion,
                 :wall,
                 :to => :actor!

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

        def with_received_ties
          joins(:actor => :received_ties)
        end
      end
    end
  end
end
