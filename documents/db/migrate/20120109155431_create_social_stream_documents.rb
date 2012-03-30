class CreateSocialStreamDocuments < ActiveRecord::Migration

  def change
    create_table "documents", :force => true do |t|
      t.string   "type"
      t.integer  "activity_object_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "file_file_name"
      t.string   "file_content_type"
      t.string   "file_file_size"
      t.boolean  "file_processing"
      t.string   "title"
      t.text     "description"
    end

    add_index "documents", ["activity_object_id"], :name => "index_documents_on_activity_object_id"

    add_foreign_key "documents", "activity_objects", :name => "documents_on_activity_object_id"

  end
end
