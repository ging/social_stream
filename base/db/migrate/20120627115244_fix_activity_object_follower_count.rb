# Reset follower_count for all the ActivityObjects that are not Actors
# See: https://github.com/ging/social_stream/issues/274
class FixActivityObjectFollowerCount < ActiveRecord::Migration
  def up
    ActivityObject.record_timestamps = false

    ActivityObject.where("object_type != ?", "Actor").all.each do |ao|
      ao.update_attribute :follower_count, ao.received_actions.where(:follow => true).count
    end

    ActivityObject.record_timestamps = true
    ActivityObject.reset_column_information
  end

  def down
  end
end
