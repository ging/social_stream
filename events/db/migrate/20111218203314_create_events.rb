class CreateEvents < ActiveRecord::Migration
  def change
    create_table "events", :force => true do |t|
      t.integer  "activity_object_id"
      t.string   "title"
      t.datetime "start_at"
      t.datetime "end_at"
      t.boolean  "all_day"
      t.datetime "created_at",                        :null => false
      t.datetime "updated_at",                        :null => false
      t.integer  "room_id"
      t.date     "start_date"
      t.date     "end_date"
      t.integer  "frequency",          :default => 0
      t.integer  "interval"
      t.integer  "days",               :default => 0
      t.integer  "interval_flag",      :default => 0
    end

    add_index "events", ["room_id"], :name => "index_events_on_room_id"

    create_table "rooms", :force => true do |t|
      t.integer  "actor_id"
      t.string   "name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "rooms", ["actor_id"], :name => "index_rooms_on_actor_id"

    add_foreign_key "events", "rooms", :name => "index_events_on_room_id"
  end
end
