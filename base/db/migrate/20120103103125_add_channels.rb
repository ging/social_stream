class AddChannels < ActiveRecord::Migration
  def up
    create_table :channels do |t|
      t.integer :author_id
      t.integer :owner_id
      t.integer :user_author_id

      t.timestamps
    end

    add_index "channels", "author_id"
    add_index "channels", "owner_id"
    add_index "channels", "user_author_id"

    add_foreign_key "channels", "actors", :name => "index_channels_on_author_id", :column => :author_id
    add_foreign_key "channels", "actors", :name => "index_channels_on_owner_id", :column => :owner_id
    add_foreign_key "channels", "actors", :name => "index_channels_on_user_author_id", :column => :user_author_id

    change_table :activity_objects do |t|
      t.integer :channel_id
    end

    add_index "activity_objects", "channel_id"

    add_foreign_key "activity_objects", "channels", :name => "index_activity_objects_on_channel_id"

    ActivityObject.record_timestamps = false

    ActivityObject.reset_column_information

    ActivityObject.all.each do |a|
      %w( author user_author owner ).each do |m|
        a.channel!.__send__ "#{ m }_id=",  a.read_attribute("#{ m }_id") # a.channel!.author_id = a.read_attribute("author_id")
      end

      a.save!
    end

    remove_foreign_key "activity_objects", :name => "index_activity_objects_on_author_id"
    remove_foreign_key "activity_objects", :name => "index_activity_objects_on_owner_id"
    remove_foreign_key "activity_objects", :name => "index_activity_objects_on_user_author_id"

    remove_column :activity_objects, :author_id
    remove_column :activity_objects, :owner_id
    remove_column :activity_objects, :user_author_id

    ActivityObject.reset_column_information
  end

  def down
    change_table :activity_objects do |t|
      t.integer :author_id
      t.integer :owner_id
      t.integer :user_author_id
    end

    add_index "activity_objects", "author_id"
    add_index "activity_objects", "owner_id"
    add_index "activity_objects", "user_author_id"

    add_foreign_key "activity_objects", "actors", :name => "index_activity_objects_on_author_id", :column => :author_id
    add_foreign_key "activity_objects", "actors", :name => "index_activity_objects_on_owner_id", :column => :owner_id
    add_foreign_key "activity_objects", "actors", :name => "index_activity_objects_on_user_author_id", :column => :user_author_id

    ActivityObject.reset_column_information
    ActivityObject.record_timestamps = false

    ActivityObject.all.each do |a|
      next if a.channel.blank?

      a.author_id      = a.channel.author_id
      a.owner_id       = a.channel.owner_id
      a.user_author_id = a.channel.user_author_id

      a.save!
    end

    remove_foreign_key "activity_objects", :name => "index_activity_objects_on_channel_id"

    remove_column :activity_objects, :channel_id

    remove_foreign_key "channels", :name => "index_channels_on_author_id"
    remove_foreign_key "channels", :name => "index_channels_on_owner_id"
    remove_foreign_key "channels", :name => "index_channels_on_user_author_id"

    drop_table :channels
  end
end
