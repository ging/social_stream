class AddLinksForeignKey < ActiveRecord::Migration
  def up
    add_foreign_key "links", "activity_objects", :name => "links_on_activity_object_id"
  end

  def down
    remove_foreign_key "links", :name => "links_on_activity_object_id"
  end
end
