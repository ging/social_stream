require 'active_support/concern'

module SocialStream
  module Models
    # Additional features for models that are Activity Objects
    module Object
      extend ActiveSupport::Concern

      included do
        attr_accessor :_activity_tie_id
        attr_accessor :_activity_parent_id

        belongs_to :activity_object, :dependent => :destroy
        has_many   :activity_object_activities, :through => :activity_object

        delegate :post_activity,
                 :like_count,
                 :to => :activity_object

        before_create :create_activity_object_with_type

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

	# before_create callback
	#
        # Build corresponding ActivityObject including this class type
        def create_activity_object_with_type #:nodoc:
          o = create_activity_object! :object_type => self.class.to_s
	  # WEIRD: Rails 3.1.0.rc3 does not assign activity_object_id
	  self.activity_object_id = o.id
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
