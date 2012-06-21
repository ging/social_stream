class AddCommentCountToActivityObject < ActiveRecord::Migration
  def up
    add_column :activity_objects, :comment_count, :integer, :default => 0

    ActivityObject.record_timestamps = false
    ActivityObject.reset_column_information

    ActivityObject.all.each do |ao|
      ao.comment_count = Activity.includes(:activity_objects).where('activity_objects.object_type' => "Comment").where(:ancestry => [ao.activities.first.id]).size
      ao.save! if ao.comment_count > 0
    end

    ActivityObject.record_timestamps = true
    ActivityObject.reset_column_information
  end

  def down
    remove_column :activity_objects, :comment_count
  end
end
