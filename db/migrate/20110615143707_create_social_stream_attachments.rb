class CreateSocialStreamAttachments < ActiveRecord::Migration
  
  def self.up
    create_table "attachments", :force => true do |t|
      t.string   "type"
      t.integer  "activity_object_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "file_file_name"
      t.string   "file_content_type"
      t.string   "file_file_size"
    end
    
    add_index "attachments", "activity_object_id"
    add_foreign_key "attachments", "activity_objects", :name => "attachments_on_activity_object_id"
    
  end
  
  def self.down
    remove_foreign_key "attachments", :name => "attachments_on_activity_object_id"
    drop_table :attachments
  end
  
end
