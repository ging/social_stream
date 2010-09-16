class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.references :activity_object
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
