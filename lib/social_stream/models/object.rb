require 'active_support/concern'

module SocialStream
  module Models
    # Additional features for models that are Activity Objects
    module Object
      extend ActiveSupport::Concern

      included do
        attr_accessor :_activity_tie_id
        attr_accessor :_activity_parent_id

        belongs_to :activity_object, :dependent => :destroy, :autosave => true
        has_many   :activity_object_activities, :through => :activity_object

        delegate :post_activity, :to => :activity_object

        alias_method_chain :create_activity_object, :type
        before_create :create_activity_object

        unless self == Actor
          before_create :create_post_activity
          before_update :create_update_activity

          validates_presence_of :_activity_tie
        end
      end

      module InstanceMethods
        # All the activities with this object
        def activities
          Activity.
            includes(:activity_objects => self.class.to_s.underscore).
            where("#{ self.class.quoted_table_name }.id" => self.id)
        end

        # The activity in which this object was posted
        #
        # FIXME: Currently it only supports direct objects
        def post_activity
          (activities.includes(:activity_verb) & ActivityVerb.verb_name('post')).first
        end

        # Create corresponding ActivityObject including this class type
        def create_activity_object_with_type(attributes = {}) #:nodoc:
          create_activity_object_without_type attributes.update(:object_type => self.class.to_s)
        end

        def _activity_tie
          @_activity_tie ||= Tie.find(_activity_tie_id)
        end

        private

        def create_post_activity
          create_activity "post"
        end

        def create_update_activity
          create_activity "update"
        end

        def create_activity(verb)
          a = Activity.new :verb      => verb,
                           :_tie      => _activity_tie,
                           :parent_id => _activity_parent_id

          a.activity_objects << activity_object

          a.save!
        end
      end
    end
  end
end
