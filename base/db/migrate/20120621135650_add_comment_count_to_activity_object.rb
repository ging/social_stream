class AddCommentCountToActivityObject < ActiveRecord::Migration
  def up
    add_column :activity_objects, :comment_count, :integer, :default => 0

    ActivityObject.record_timestamps = false
    ActivityObject.reset_column_information

    ActivityObject.all.each do |ao|
      parent_activity = ao.activities.first

      # Actors have not parent activities
      next if parent_activity.blank?

      ao.update_attribute(:comment_count, Activity.includes(:activity_objects).where('activity_objects.object_type' => "Comment").where(:ancestry => [parent_activity.id]).size)
    end

    ActivityObject.record_timestamps = true
    ActivityObject.reset_column_information
  end

  def down
    remove_column :activity_objects, :comment_count
  end
end
