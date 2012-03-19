class CreateActivityActions < ActiveRecord::Migration
  def change
    create_table :activity_actions do |t|
      t.references :actor
      t.references :activity_object

      t.timestamps
    end
    add_index :activity_actions, :actor_id
    add_index :activity_actions, :activity_object_id

    add_foreign_key "activity_actions", "actors", :name => "index_activity_actions_on_actor_id"
    add_foreign_key "activity_actions", "activity_objects", :name => "index_activity_actions_on_activity_object_id"
  end
end
