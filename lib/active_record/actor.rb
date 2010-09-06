require 'active_support/concern'

module ActiveRecord
  module Actor
    extend ActiveSupport::Concern

    included do
      belongs_to :actor,
                 :validate => true,
                 :autosave => true

      delegate :name, :name=, :email, :email=, :ties,
               :to => :actor!

      ::Actor.subtype(self)
    end

    module InstanceMethods

      def actor!
        actor || build_actor
      end
    end
  end
end
