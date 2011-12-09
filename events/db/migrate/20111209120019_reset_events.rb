class ResetEvents < ActiveRecord::Migration
  def up
    remove_foreign_key "agendas", :name => "agendas_on_activity_object_id"
    remove_foreign_key "agendas", :name => "agendas_on_event_id"

    remove_foreign_key "events", :name => "events_on_actor_id"

    remove_foreign_key "sessions", :name => "sessions_on_activity_object_id"
    remove_foreign_key "sessions", :name => "sessions_on_agenda_id"
   
    drop_table :sessions
    drop_table :agendas
    drop_table :events           
  end

  def down
  end
end
