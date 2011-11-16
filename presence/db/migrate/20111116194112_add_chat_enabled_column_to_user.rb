class AddChatEnabledColumnToUser < ActiveRecord::Migration
  def self.up
     add_column :users, :chat_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :users, :chat_enabled
  end
end
