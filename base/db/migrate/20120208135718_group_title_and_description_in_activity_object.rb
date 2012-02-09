class GroupTitleAndDescriptionInActivityObject < ActiveRecord::Migration
  def up
    change_table :activity_objects do |t|
      t.string :title, :default => ""
      t.text :description
    end

    # Fix 'comments' table
    Comment.all.each do |c|
      c.activity_object.description = c.text
      c.save!
    end
    change_table :comments do |t|
      t.remove :text
    end

    # Fix 'posts' table
    Post.all.each do |p|
      p.activity_object.description = p.text
      p.save!
    end
    change_table :posts do |t|
      t.remove :text
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Due to trans-gem oddities
  end
end
