class AddMoreFieldsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :description, :string
    add_column :events, :place, :string
    add_column :events, :isabel_event, :string
    add_column :events, :machine_id, :integer
    add_column :events, :repeat, :string
    add_column :events, :at_job, :integer
    add_column :events, :parent_id, :integer
    add_column :events, :character, :integer
    add_column :events, :public_read, :integer
    add_column :events, :marte_event, :integer
    add_column :events, :marte_room, :integer
    add_column :events, :spam, :integer
    add_column :events, :notes, :integer
    add_column :events, :location, :text
    add_column :events, :streamming_url, :text
    add_column :events, :permalink, :string
    add_column :events, :cm_event_id, :integer
    add_column :events, :vc_mode, :integer
    add_column :events, :other_participation_url, :text
    add_column :events, :web_interface, :integer
  end
end
