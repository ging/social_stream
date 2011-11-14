class AddMoreFieldsToSessions < ActiveRecord::Migration

  def change
    add_column :sessions, :speakers, :string
    add_column :sessions, :embedded_video, :text
    add_column :sessions, :video_thumbnail, :text
    add_column :sessions, :uid, :text
    add_column :sessions, :cm_session_id, :int
    add_column :sessions, :cm_streaming, :int, :default => false
    add_column :sessions, :cm_recording, :int, :default => false
  end

end
