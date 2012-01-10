require 'active_support/concern'

module SocialStream
  module Models
    # Additional features for models that are Activity Objects
    module Object
      extend ActiveSupport::Concern

      included do
        attr_writer   :_relation_ids
        attr_accessor :_activity_parent_id

        subtype_of :activity_object,
                   :build => { :object_type => to_s }

        has_one  :channel, :through => :activity_object
        has_many :activity_object_activities, :through => :activity_object

#        before_create :create_activity_object_with_type

        unless self == Actor
          validates_presence_of :author_id, :owner_id, :user_author_id

          after_create :create_post_activity
          # Disable update activity for now
          # It usually appears repeated in the wall and provides no useful information
          #after_update :create_update_activity
        end

        scope :authored_by, lambda { |subject|
          joins(:activity_object).
            merge(ActivityObject.authored_by(subject))
        }
      end

      module InstanceMethods
        # Was the author represented with this {SocialStream::Models::Object object} was created?
        def represented_author?
          author_id == user_author_id
        end

        # All the activities with this object
        def activities
          Activity.
            includes(:activity_objects => self.class.to_s.underscore).
            where("#{ self.class.quoted_table_name }.id" => self.id)
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
          @_contact ||= author && owner && author.contact_to!(owner)
        end

        def _contact_id
          _contact.try(:id)
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
