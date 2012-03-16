class ActionFollow < ActiveRecord::Migration
  def up
    add_column :actions, :follow, :boolean, :default => false
    add_column :activity_objects, :follower_count, :integer, :default => 0
    remove_column :actors, :follower_count

    ActivityObject.reset_column_information
    Actor.reset_column_information

    Tie.
      joins(:relation).
      with_permissions('follow', nil).
      each do |t|
        t.set_follow_action
      end
  end

  def down
    remove_column :actions, :follow
    remove_column :activity_objects, :follower_count
    add_column :actors, :follower_count, :integer, :default => 0
  end
end
