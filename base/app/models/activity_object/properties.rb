class ActivityObject
  # Manage all the relations between two {ActivityObject}
  #
  # By default, any {SocialStream::Models::Object object} is related with the others
  # That means that the following methods are available:
  #
  #   post.posts #=> returns all the posts that are properties of post
  #   post.documents #=> returns all the documents associated with post
  #   document.holder_posts #=> all the posts that have this document as property
  #
  # Currently, Rails does not support assigning objects directly,
  # as in post.documents << d, but you can use
  #
  #   post.property_objects << d.activity_object_id
  #
  # There are convenience method to add properties to holders without affecting
  # existing holders. For instance, if you can assign several documents to an event,
  # you can use:
  #
  #   document.add_holder_event_id = event.id
  #
  module Properties
    extend ActiveSupport::Concern

    included do
      has_many :activity_object_properties,
               dependent: :destroy,
               inverse_of: :activity_object

      has_many :property_objects,
               through: :activity_object_properties,
               source:  :property

      has_one :main_activity_object_property,
              class_name: "ActivityObjectProperty",
              conditions: { main: true }
      has_one :main_property_object,
              through: :main_activity_object_property,
              source:  :property

      has_many :activity_object_holds,
               class_name:  "ActivityObjectProperty",
               foreign_key: :property_id,
               dependent:   :destroy,
               inverse_of:  :property
      has_many :holder_objects,
               through: :activity_object_holds,
               source:  :activity_object

      has_many :main_activity_object_holds,
               class_name:  "ActivityObjectProperty",
               foreign_key: :property_id,
               conditions:  { main: true }

      has_many :main_holder_objects,
               through: :main_activity_object_holds,
               source:  :activity_object

      SocialStream.objects.each do |o|
        attr_reader "add_holder_#{ o }_id" # attr_reader "add_holder_post_id"

        has_many o.to_s.tableize,             # has_many posts,
                 through: :property_objects,  #          through: :property_objects,
                 source:  o                   #          source:  :post

        has_one  "main_#{ o }",                  # has_one :main_post,
                 through: :main_property_object, #         through: :main_property_object,
                 source: o                       #         source:  :post

        has_many "holder_#{ o.to_s.tableize }",  # has_many :holder_posts,
                 through: :holder_objects,       #          through: :holder_objects,
                 source: o                       #          source:  :post

        has_many "main_holder_#{ o.to_s.tableize }", # has_many :main_holder_posts,
                 through: :main_holder_objects,      #          through: :main_holder_objects,
                 source:  o                          #          source:  :post
      end
    end

    SocialStream.objects.each do |o|
      eval <<-EOM
        def add_holder_object_id= i
          self.holder_object_ids |= [i]
        end

        def add_holder_#{ o }_id= i
          @add_holder_#{ o }_id = i

          self.add_holder_object_id = #{ o.to_s.classify }.find(i).activity_object_id
        end
      EOM
    end
  end
end
