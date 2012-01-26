require "acts_as_taggable_on/acts_as_taggable_on/dirty"

module ActsAsTaggableOn::Taggable::Core::ClassMethods
 def initialize_acts_as_taggable_on_core
   tag_types.map(&:to_s).each do |tags_type|
     tag_type         = tags_type.to_s.singularize
     context_taggings = "#{tag_type}_taggings".to_sym
     context_tags     = tags_type.to_sym
 
     class_eval do
       has_many context_taggings, :as => :taggable, :dependent => :destroy, :include => :tag, :class_name => "ActsAsTaggableOn::Tagging",
       :conditions => ["#{ActsAsTaggableOn::Tagging.table_name}.context = ?", tags_type]
       has_many context_tags, :through => context_taggings, :source => :tag, :class_name => "ActsAsTaggableOn::Tag"
     end
 
     class_eval %(
       def #{tag_type}_list
         tag_list_on('#{tags_type}')
       end
 
       def #{tag_type}_list=(new_tags)
         set_tag_list_on('#{tags_type}', new_tags)
       end
 
       def all_#{tags_type}_list
         all_tags_list_on('#{tags_type}')
       end
     )
   end
 end
end

module ActsAsTaggableOn::Taggable::Core::InstanceMethods
  def set_tag_list_on(context, new_list)
    add_custom_context(context)

    variable_name = "@#{context.to_s.singularize}_list"
    process_dirty_object(context, new_list) unless custom_contexts.include?(context.to_s)

    instance_variable_set(variable_name, ActsAsTaggableOn::TagList.from(new_list))
  end

  def process_dirty_object(context,new_list)
    value = new_list.is_a?(Array) ? new_list.join(', ') : new_list
    attrib = "#{context.to_s.singularize}_list"

    if changed_attributes.include?(attrib)
      # The attribute already has an unsaved change.
      old = changed_attributes[attrib]
      changed_attributes.delete(attrib) if (old.to_s == value.to_s)
    else
      old = tag_list_on(context).to_s
      changed_attributes[attrib] = old if (old.to_s != value.to_s)
    end
  end
end

module ActsAsTaggableOn::Taggable
  def acts_as_taggable_on(*tag_types)
    tag_types = tag_types.to_a.flatten.compact.map(&:to_sym)

    if taggable?
        self.tag_types = (self.tag_types + tag_types).uniq
    else
        class_attribute :tag_types
        self.tag_types = tag_types

      class_eval do
        has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag, :class_name => "ActsAsTaggableOn::Tagging"
        has_many :base_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggableOn::Tag"

        def self.taggable?
          true
        end

        include ActsAsTaggableOn::Utils
        include ActsAsTaggableOn::Taggable::Core
        include ActsAsTaggableOn::Taggable::Collection
        include ActsAsTaggableOn::Taggable::Cache
        include ActsAsTaggableOn::Taggable::Ownership
        include ActsAsTaggableOn::Taggable::Related
        include ActsAsTaggableOn::Taggable::Dirty
      end
    end
  end
end
