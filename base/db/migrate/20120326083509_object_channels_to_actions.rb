class ObjectChannelsToActions < ActiveRecord::Migration
  def up
    add_column :activity_actions, :author, :boolean, :default => false
    add_column :activity_actions, :user_author, :boolean, :default => false
    add_column :activity_actions, :owner, :boolean, :default => false

    ActivityAction.reset_column_information
    ActivityAction.record_timestamps = false
    ActivityObject.record_timestamps = false

    ActivityObject.all.each do |ao|
      channel = Channel.find ao.channel_id

      %w{ author user_author owner }.each do |role|
        next unless channel.__send__ "#{ role }_id"

        ao.__send__"#{ role }_id=", channel.__send__("#{ role }_id")
      end

      ao.received_actions.each do |a|
        a.created_at = a.updated_at = ao.created_at
      end

      ao.save!
    end

    remove_foreign_key :activity_objects, :name => "index_activity_objects_on_channel_id"
    remove_column :activity_objects, :channel_id

    ActivityObject.reset_column_information

    ActivityAction.record_timestamps = true
    ActivityObject.record_timestamps = true
  end

  def down
    remove_column :activity_actions, :author
    remove_column :activity_actions, :user_author
    remove_column :activity_actions, :owner

    add_column :activity_objects, :channel_id, :integer
    add_index  :activity_objects, :channel_id
    add_foreign_key :activity_actions, :channel_id, :name => "index_activity_objects_on_channel_id"
  end
end
