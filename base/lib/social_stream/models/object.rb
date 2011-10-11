require 'active_support/concern'

module SocialStream
  module Models
    # Additional features for models that are Activity Objects
    module Object
      extend ActiveSupport::Concern

      included do
        attr_accessor :_contact_id
        attr_writer   :_relation_ids
        attr_accessor :_activity_parent_id

        belongs_to :activity_object, :dependent => :destroy, :autosave => true
        has_many   :activity_object_activities, :through => :activity_object

        delegate :post_activity,
                 :like_count,
                 :tag_list, :tag_list=,
                 :tagged_with, :tag_counts,
                 :to => :activity_object!

        before_create :create_activity_object_with_type

        unless self == Actor
          validates_presence_of :_contact_id, :on => :create

          after_create :create_post_activity
          after_update :create_update_activity
        end
      end

      module InstanceMethods
        def activity_object!
          activity_object || build_activity_object(:object_type => self.class.to_s)
        end

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

        # Build the post activity when this object is not saved
        def build_post_activity
          Activity.new :contact_id   => _contact_id,
                       :relation_ids => Array(_relation_ids)
        end

	# before_create callback
	#
        # Build corresponding ActivityObject including this class type
        def create_activity_object_with_type #:nodoc:
          o = create_activity_object! :object_type => self.class.to_s
	  # WEIRD: Rails 3.1.0.rc3 does not assign activity_object_id
	  self.activity_object_id = o.id
        end

        def _contact
          @_contact ||= Contact.find(_contact_id)
        end

        def _relation_ids
          @_relation_ids ||=
            if _contact_id.nil?
              nil
            else
              # FIXME: repeated in Activity#fill_relations
              if _contact.reflexive?
                _contact.sender.relation_customs.map(&:id)
              else
                 _contact.
                   receiver.
                   relation_customs.
                   allow(_contact.sender, 'create', 'activity').
                   map(&:id)
              end
            end
        end

        def _activity_parent
          @_activity_parent ||= Activity.find(_activity_parent_id)
        end

        # The {SocialStream::Models::Subject subject} that posted this object
        def _author
          post_activity.contact.sender_subject
        end

        # The owner of the wall where {#_author} posted this object
        def _owner
          post_activity.contact.receiver_subject
        end

        private

        def create_post_activity
          create_activity "post"
        end

        def create_update_activity
          return if _contact_id.blank?
          
          create_activity "update"
        end

        def create_activity(verb)
          a = Activity.new :verb         => verb,
                           :contact      => _contact,
                           :relation_ids => _relation_ids,
                           :parent_id    => _activity_parent_id

          a.activity_objects << activity_object

          a.save!
        end
      end
    end
  end
end
