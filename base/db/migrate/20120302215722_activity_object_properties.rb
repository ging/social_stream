class ActivityObjectProperties < ActiveRecord::Migration
  def up
    create_table :activity_object_properties do |t|
      t.integer :activity_object_id
      t.integer :property_id
      t.string  :type
      
      t.timestamp
    end

    add_index "activity_object_properties", "activity_object_id"
    add_index "activity_object_properties", "property_id"

    add_foreign_key "activity_object_properties", "activity_objects", :name => "index_activity_object_properties_on_activity_object_id", :column => :activity_object_id
    add_foreign_key "activity_object_properties", "activity_objects", :name => "index_activity_object_properties_on_property_id", :column => :property_id
  end

  def down
    remove_foreign_key "activity_object_properties", :name => "index_activity_object_properties_on_activity_object_id"
    remove_foreign_key "activity_object_properties", :name => "index_activity_object_properties_on_property_id"

    drop_table :activity_object_properties
  end
end
