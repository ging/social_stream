class GroupTitleAndDescriptionInActivityObject < ActiveRecord::Migration
  def up
    ActivityObject.record_timestamps = false
    change_table :activity_objects do |t|
      t.string :title, :default => ""
      t.text :description
    end

    # Fix 'comments' table
    Comment.record_timestamps = false
    Comment.all.each do |c|
      c.activity_object.description = c.text
      c.save!
    end
    change_table :comments do |t|
      t.remove :text
    end
    Comment.reset_column_information

    # Fix 'posts' table
    Post.record_timestamps = false
    Post.all.each do |p|
      p.activity_object.description = p.text
      p.save!
    end
    change_table :posts do |t|
      t.remove :text
    end
    Post.reset_column_information
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Due to trans-gem oddities
  end
end
