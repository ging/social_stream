require "acts_as_taggable_on/acts_as_taggable_on/dirty"

module ActsAsTaggableOn::Taggable
  def acts_as_taggable_on(*tag_types)
    tag_types = tag_types.to_a.flatten.compact.map(&:to_sym)

    if taggable?
      write_inheritable_attribute(:tag_types, (self.tag_types + tag_types).uniq)
    else
      write_inheritable_attribute(:tag_types, tag_types)
      class_inheritable_reader(:tag_types)

      class_eval do
        has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag, :class_name => "ActsAsTaggableOn::Tagging"
        has_many :base_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggableOn::Tag"

        def self.taggable?
          true
        end

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


module ActsAsTaggableOn::Taggable::Core::InstanceMethods
  def set_tag_list_on(context, new_list)
    add_custom_context(context)

    variable_name = "@#{context.to_s.singularize}_list"
    process_dirty_object(context, new_list)        

    instance_variable_set(variable_name, ActsAsTaggableOn::TagList.from(new_list))
  end

  def process_dirty_object(context,new_list)
    value = new_list.is_a?(Array) ? new_list.join(', ') : new_list
    attr = "#{context.to_s.singularize}_list"

    if changed_attributes.include?(attr)
      # The attribute already has an unsaved change.
      old = changed_attributes[attr]
      changed_attributes.delete(attr) if (old.to_s == value.to_s)
    else
      old = tag_list_on(context).to_s
      changed_attributes[attr] = old if (old.to_s != value.to_s)
    end
  end
end


