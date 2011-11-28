class AddDetailsToEvents < ActiveRecord::Migration

  def change
    add_column :events, :marte_event, :boolean, :default => false
    add_column :events, :spam, :boolean, :default => false
    add_column :events, :vc_mode, :integer , :default => 0
    add_column :events, :web_interface, :string, :default => false
    add_column :events, :isabel_interface, :string, :default => false
    add_column :events, :sip_interface, :string, :default => false
    add_column :events, :streaming_by_default, :string, :default => true
    add_column :events, :manual_configuration, :string, :default => false
    add_column :events, :recording_type, :string, :default => 0

    add_column :events, :isabel_bw, :text
    add_column :events, :web_bw, :integer
    add_column :events, :recording_bw, :integer
  end
end
