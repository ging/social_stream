class ActorNotificationSettings < ActiveRecord::Migration
  def change
    change_table :actors do |t|
      t.string "notification_settings"
    end
  end
end
