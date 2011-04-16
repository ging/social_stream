class CreateSocial2social < ActiveRecord::Migration
  
  def self.up
    create_table :remote_users, :force => true do |t|
      t.integer :actor_id
      t.string :webfinger_slug
      t.string :hub_url
      t.string :origin_node_url
      t.timestamps
    end
    
    add_index "remote_users", "actor_id"
    add_foreign_key "remote_users", "actors", :name => "remote_users_on_actor_id"
  end
  
  def self.down
    remove_foreign_key "remote_users", :name => "remote_users_on_actor_id"
    drop_table :remote_users
  end
  
end