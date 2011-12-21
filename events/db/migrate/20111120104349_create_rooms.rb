class CreateRooms < ActiveRecord::Migration
  def up
    create_table :rooms do |t|
      t.references :actor
      t.string :name

      t.timestamps
    end

    change_table :events do |t|
      t.references :room
    end

    add_index :rooms, :actor_id
    add_index :events, :room_id
    add_foreign_key :rooms, :actors, :name => "index_rooms_on_actor_id"
    add_foreign_key :events, :rooms, :name => "index_events_on_room_id"
  end

  def down
    remove_foreign_key :rooms, :name => "index_rooms_on_actor_id"
    remove_foreign_key :events, :name => "index_events_on_room_id"

    drop_table :rooms
  end
end
