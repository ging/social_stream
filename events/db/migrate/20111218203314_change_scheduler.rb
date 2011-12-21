class ChangeScheduler < ActiveRecord::Migration
  def up
    rename_column :events, :interval_flag, :days
    add_column :events, :interval_flag, :integer, :default => 0
  end

  def down
    rename_column :events, :days, :interval_flag
    remove_column :events, :interval_flag
  end
end
