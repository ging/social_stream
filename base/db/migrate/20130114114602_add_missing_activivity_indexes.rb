class AddMissingActivivityIndexes < ActiveRecord::Migration
  def up
    add_index "activities", "author_id", :name => "index_activities_on_author_id"
    add_index "activities", "user_author_id", :name => "index_activities_on_user_author_id"
    add_index "activities", "owner_id", :name => "index_activities_on_owner_id"

    add_foreign_key "activities", "actors", :column => :author_id, :name => "index_activities_on_author_id"
    add_foreign_key "activities", "actors", :column => :user_author_id, :name => "index_activities_on_user_author_id"
    add_foreign_key "activities", "actors", :column => :owner_id, :name => "index_activities_on_owner_id"
  end

  def down
    remove_foreign_key "activities", :name => "index_activities_on_author_id"
    remove_foreign_key "activities", :name => "index_activities_on_user_author_id"
    remove_foreign_key "activities", :name => "index_activities_on_owner_id"
  end
end
