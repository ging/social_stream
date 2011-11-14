class AddDetailsToEvents < ActiveRecord::Migration

  def change
    remove_column :events, :marte_event
    remove_column :events, :spam
    remove_column :events, :vc_mode
    remove_column :events, :web_interface
    add_column :events, :marte_event, :int, :default => false
    add_column :events, :spam, :int, :default => false
    add_column :events, :vc_mode, :int , :default => 0
    add_column :events, :web_interface, :string, :default => false
    add_column :events, :isabel_interface, :string, :default => false
    add_column :events, :sip_interface, :string, :default => false
    add_column :events, :streaming_by_default, :string, :default => true
    add_column :events, :manual_configuration, :string, :default => false
    add_column :events, :recording_type, :string, :default => 0

    add_column :events, :isabel_bw, :text
    add_column :events, :web_bw, :integer
    add_column :events, :recording_bw, :integer



=begin

    add_column :events, :enable_httplivestreaming
    add_column :events, :enable_httplivestreaming
    add_column :events, :enable_httplivestreaming
    add_column :events, :enable_httplivestreaming


            :enable_httplivestreaming => "0",
            :isabel_bw => isabel_bw,
            :web_bw => WEB_BANDWIDTH[web_bw],
            :recording_bw => RECORDING_BANDWIDTH[recording_bw],
            :httplivestreaming_bw => WEB_BANDWIDTH[web_bw],
            :web_codec => WEB_CODEC[web_bw],
            :recording_codec => RECORDING_CODEC[recording_bw],
            :path => "attachments/conferences/#{permalink}"

=end
  end

end