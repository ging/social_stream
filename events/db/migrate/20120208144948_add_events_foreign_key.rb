class AddEventsForeignKey < ActiveRecord::Migration
  def up
    add_foreign_key "events", "activity_objects", :name => "events_on_activity_object_id"
  end

  def down
    remove_foreign_key "events", :name => "events_on_activity_object_id"
  end
end
