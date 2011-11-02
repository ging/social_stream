class FieldsEvents < ActiveRecord::Migration


  def change
    add_column :events, :description, :string
    add_column :events, :place, :string
    add_column :events, :isabel_event, :string
    add_column :events, :machine_id, :int
    add_column :events, :repeat, :string
    add_column :events, :at_job, :int
    add_column :events, :parent_id, :int
    add_column :events, :character, :int
    add_column :events, :public_read, :int
    add_column :events, :marte_event, :int
    add_column :events, :marte_room, :int
    add_column :events, :spam, :int
    add_column :events, :notes, :int
    add_column :events, :location, :text
    add_column :events, :streamming_url, :text
    add_column :events, :permalink, :string
    add_column :events, :cm_event_id, :int
    add_column :events, :vc_mode, :int
    add_column :events, :other_participation_url, :text
    add_column :events, :web_interface, :int

  end

end
