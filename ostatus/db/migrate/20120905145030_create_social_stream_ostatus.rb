class CreateSocialStreamOstatus < ActiveRecord::Migration
  
  def change
    create_table :actor_keys do |t|
      t.integer :actor_id
      t.binary  :key_der

      t.timestamps
    end

    add_index "actor_keys", "actor_id"

    create_table :remote_subjects, :force => true do |t|
      t.integer :actor_id
      t.string  :webfinger_id
      t.text    :webfinger_info
      t.timestamps
    end
    
    add_index "remote_subjects", "actor_id"

    add_foreign_key "actor_keys", "actors", :name => "actor_keys_on_actor_id"

    add_foreign_key "remote_subjects", "actors", :name => "remote_subjects_on_actor_id"
  end
end
