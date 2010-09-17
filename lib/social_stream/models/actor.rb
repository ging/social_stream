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
                 :ties,
                 :to => :actor!
      end

      module InstanceMethods
        def actor!
          actor || build_actor
        end
      end
    end
  end
end
