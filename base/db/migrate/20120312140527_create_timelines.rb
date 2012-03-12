class CreateTimelines < ActiveRecord::Migration
  def change
    create_table :timelines do |t|
      t.references :activity
      t.references :actor

      t.timestamps
    end
    add_index :timelines, :activity_id
    add_index :timelines, :actor_id

    add_foreign_key "timelines", "activities", :name => "index_timelines_on_activity_id"
    add_foreign_key "timelines", "actors", :name => "index_timelines_on_actor_id"
  end
end
