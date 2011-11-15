class AddMoreFieldsToSessions < ActiveRecord::Migration

  def change
    add_column :sessions, :speakers, :string
    add_column :sessions, :embedded_video, :text
    add_column :sessions, :video_thumbnail, :text
    add_column :sessions, :uid, :text
    add_column :sessions, :cm_session_id, :integer
    add_column :sessions, :cm_streaming, :boolean, :default => false
    add_column :sessions, :cm_recording, :boolean, :default => false
  end

end
