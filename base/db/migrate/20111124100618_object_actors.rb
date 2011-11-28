class ObjectActors < ActiveRecord::Migration
  def up
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

    ActivityObject.record_timestamps = false

    ActivityObject.all.each do |a|
      if a.object_type == "Actor"
        next if a.object.is_a? User

        author = user_author = a.object.sent_ties.order(:created_at).first.receiver

        until user_author.subject_type == "User"
          user_author = user_author.sent_ties.order(:created_at).first.receiver
        end

        a.author = author
        a.user_author = user_author
      else
        next if a.post_activity.blank?

        a.author = a.post_activity.sender
        a.owner  = a.post_activity.receiver
        a.user_author = (a.author.subject.is_a?(User) ? a.author : a.author.sent_ties.order(:created_at).first.receiver)
      end

      a.save!
    end
  end

  def down
    remove_foreign_key "activity_objects", :name => "index_activity_objects_on_author_id"
    remove_foreign_key "activity_objects", :name => "index_activity_objects_on_owner_id"
    remove_foreign_key "activity_objects", :name => "index_activity_objects_on_user_author_id"

    remove_column :activity_objects, :author_id
    remove_column :activity_objects, :owner_id
    remove_column :activity_objects, :user_author_id
  end
end
