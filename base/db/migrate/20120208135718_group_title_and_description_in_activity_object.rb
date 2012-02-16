class GroupTitleAndDescriptionInActivityObject < ActiveRecord::Migration
  def up
    ao_ts = ActivityObject.record_timestamps
    ActivityObject.record_timestamps = false

    change_table :activity_objects do |t|
      t.string :title, :default => ""
      t.text :description
    end

    ActivityObject.reset_column_information

    # Fix 'comments' table
    c_ts = Comment.record_timestamps
    Comment.record_timestamps = false

    Comment.all.each do |c|
      # Remove comments that are not properly deleted
      # https://github.com/ging/social_stream/issues/213
      if c.activity_object.activities.blank?
        c.destroy
        next
      end

      c.activity_object.description = c.read_attribute(:text)
      c.save!
    end
    change_table :comments do |t|
      t.remove :text
    end
    Comment.reset_column_information
    Comment.record_timestamps = c_ts

    # Fix 'posts' table
    p_ts = Post.record_timestamps
    Post.record_timestamps = false

    Post.all.each do |p|
      p.activity_object.description = p.read_attribute(:text)
      p.save!
    end
    change_table :posts do |t|
      t.remove :text
    end
    Post.reset_column_information
    Post.record_timestamps = p_ts

    ActivityObject.record_timestamps = ao_ts
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Due to trans-gem oddities
  end
end
