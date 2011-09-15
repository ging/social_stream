class CreateSocialStreamEvents < ActiveRecord::Migration
  
  def self.up

  create_table :events do |t|
    t.references :actor
    t.datetime :start_at
    t.datetime :end_at
    t.integer :founder_id
    t.timestamps
  end

  create_table :agendas do |t|
    t.references :activity_object
    t.references :event
    t.timestamps
  end

  create_table :sessions do |t|
    t.references :activity_object
    t.references :agenda
    t.datetime :start_at
    t.datetime :end_at
    t.string   :title
    t.string  :description
    t.timestamps
  end


  add_foreign_key "agendas", "activity_objects", :name => "agendas_on_activity_object_id"
  add_foreign_key "agendas", "events", :name => "agendas_on_event_id"

  add_foreign_key "events", "actors", :name => "events_on_actor_id"

  add_foreign_key "sessions", "activity_objects", :name => "sessions_on_activity_object_id"
  add_foreign_key "sessions", "agendas", :name => "sessions_on_agenda_id"
   
  end
  
  def self.down
    remove_foreign_key "agendas", :name => "agendas_on_activity_object_id"
    remove_foreign_key "agendas", :name => "agendas_on_event_id"

    remove_foreign_key "events", :name => "events_on_actor_id"

    remove_foreign_key "sessions", :name => "sessions_on_activity_object_id"
    remove_foreign_key "sessions", :name => "sessions_on_agenda_id"
   
    drop_table :sessions
    drop_table :agendas
    drop_table :events           
  end
  
end
