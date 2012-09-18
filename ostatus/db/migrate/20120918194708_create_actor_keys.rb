class CreateActorKeys < ActiveRecord::Migration
  def up
    create_table :actor_keys do |t|
      t.integer :actor_id
      t.binary  :key_der

      t.timestamps
    end

    add_index "actor_keys", "actor_id"
    add_foreign_key "actor_keys", "actors", :name => "actor_keys_on_actor_id"
  end

  def down
    remove_foreign_key "actor_keys", :name => "actor_keys_on_actor_id"
    drop_table :actor_keys
  end
end
