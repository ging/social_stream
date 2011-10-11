class AddConnectedColumnToUser < ActiveRecord::Migration
  def self.up
     add_column :users, :connected, :boolean, :default => false
  end

  def self.down
    remove_column :users, :connected
  end
end
