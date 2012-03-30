class CreateSocialStreamLinkser < ActiveRecord::Migration
  def change
    create_table "links", :force => true do |t|
      t.integer  "activity_object_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "url"
      t.string   "callback_url"
      t.string   "title"
      t.string   "image"
      t.text     "description"
      t.integer  "width",              :default => 470
      t.integer  "height",             :default => 353
    end

    add_index "links", ["activity_object_id"], :name => "index_links_on_activity_object_id"
  end
end
