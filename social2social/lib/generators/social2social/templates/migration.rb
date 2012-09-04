class CreateSocial2social < ActiveRecord::Migration
  
  def self.up
    create_table :remote_subjects, :force => true do |t|
      t.integer :actor_id
      t.string :webfinger_slug
      t.string :hub_url
      t.string :origin_node_url
      t.timestamps
    end
    
    add_index "remote_subjects", "actor_id"
    add_foreign_key "remote_subjects", "actors", :name => "remote_subjects_on_actor_id"
  end
  
  def self.down
    remove_foreign_key "remote_subjects", :name => "remote_subjects_on_actor_id"
    drop_table :remote_subjects
  end
  
end