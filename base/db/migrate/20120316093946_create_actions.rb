class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.references :actor
      t.references :activity_object

      t.timestamps
    end
    add_index :actions, :actor_id
    add_index :actions, :activity_object_id

    add_foreign_key "actions", "actors", :name => "index_actions_on_actor_id"
    add_foreign_key "actions", "activity_objects", :name => "index_actions_on_activity_object_id"
  end
end
