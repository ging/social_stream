class CreateSocialStream < ActiveRecord::Migration
  def self.up
    create_table "activities", :force => true do |t|
      t.integer  "activity_verb_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "ancestry"
    end
    
    add_index "activities", "activity_verb_id"
    
    create_table "activity_object_activities", :force => true do |t|
      t.integer  "activity_id"
      t.integer  "activity_object_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "object_type"
    end
    
    add_index "activity_object_activities", "activity_id"
    add_index "activity_object_activities", "activity_object_id"
    
    create_table "activity_objects", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "object_type", :limit => 45
      t.integer  "like_count", :default => 0
    end
    
    create_table "activity_verbs", :force => true do |t|
      t.string   "name",       :limit => 45
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "actors", :force => true do |t|
      t.string   "name"
      t.string   "email",     :default => "", :null => false
      t.string   "slug"
      t.string   "subject_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "activity_object_id"
      t.integer  "follower_count", :default => 0
    end
    
    add_index "actors", "activity_object_id"
    add_index "actors", "email"
    add_index "actors", "slug", :unique => true
    
    create_table :authentications, :force => true do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.timestamps
    end
    
    add_index "authentications", "user_id"

    create_table "avatars", :force => true do |t|
      t.integer  "actor_id"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.boolean  "active", :default => true
    end
    
    add_index "avatars", "actor_id"
   
    create_table "comments", :force => true do |t|
      t.integer  "activity_object_id"
      t.text     "text"
      t.datetime "updated_at"
      t.datetime "created_at"
    end
    
    add_index "comments", "activity_object_id"
    
    create_table "groups", :force => true do |t|
      t.integer  "actor_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    add_index "groups", "actor_id"
    
    create_table "permissions", :force => true do |t|
      t.string   "action"
      t.string   "object",   :default => nil
      t.string   "function", :default => nil
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
      
    create_table "posts", :force => true do |t|
      t.integer  "activity_object_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "text"
    end
    
    add_index "posts", "activity_object_id"
    
    create_table "profiles", :force => true do |t|
      t.integer  "actor_id"
      t.date     "birthday"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "organization", :limit => 45
      t.string   "phone",        :limit => 45
      t.string   "mobile",       :limit => 45
      t.string   "fax",          :limit => 45
      t.string   "address"
      t.string   "city"
      t.string   "zipcode",      :limit => 45
      t.string   "province",     :limit => 45
      t.string   "country",      :limit => 45
      t.integer  "prefix_key"
      t.string   "description"
      t.string   "experience"
      t.string   "website"
      t.string   "skype",        :limit => 45
      t.string   "im",           :limit => 45
    end
    
    add_index "profiles", "actor_id"
    
    create_table "relation_permissions", :force => true do |t|
      t.integer  "relation_id"
      t.integer  "permission_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "relation_id"
    end
    
    add_index "relation_permissions", "relation_id"
    add_index "relation_permissions", "permission_id"
    
    create_table "relations", :force => true do |t|
      t.string   "type"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "sender_type"
      t.string   "receiver_type"
      t.string   "ancestry"
      t.integer  "sphere_id"
    end
    
    add_index "relations", "ancestry"
    add_index "relations", "sphere_id"

    create_table "spheres", :force => true do |t|
      t.string   "name"
      t.integer  "actor_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "spheres", "actor_id"
    
    create_table "tie_activities", :force => true do |t|
      t.integer "tie_id"
      t.integer "activity_id"
      t.boolean "read"
      t.boolean "original", :default => true
    end
    
    add_index "tie_activities", "tie_id"
    add_index "tie_activities", "activity_id"
    
    create_table "ties", :force => true do |t|
      t.integer  "sender_id"
      t.integer  "receiver_id"
      t.integer  "relation_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "original", :default => true
    end
    
    add_index "ties", "receiver_id"
    add_index "ties", "relation_id"
    add_index "ties", "sender_id"
    
    create_table "users", :force => true do |t|
      t.string :encrypted_password, :null => false, :default => "", :limit => 128
      t.string :password_salt
      
      t.recoverable
      t.rememberable
      t.trackable
      
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable
      
      t.timestamps
      t.integer  "actor_id"
    end
    
    add_index "users", "actor_id"
    add_index "users", :reset_password_token, :unique => true
    # add_index :users, :confirmation_token, :unique => true
    # add_index :users, :unlock_token,       :unique => true
    
    add_foreign_key "activities", "activity_verbs", :name => "index_activities_on_activity_verb_id"
    
    add_foreign_key "activity_object_activities", "activities", :name => "index_activity_object_activities_on_activity_id"
    add_foreign_key "activity_object_activities", "activity_objects", :name => "activity_object_activities_on_activity_object_id"
    
    add_foreign_key "actors", "activity_objects", :name => "actors_on_activity_object_id"
    
    add_foreign_key "authentications", "users", :name => "authentications_on_user_id"

    add_foreign_key "avatars", "actors", :name => "avatars_on_actor_id"
    
    add_foreign_key "comments", "activity_objects", :name => "comments_on_activity_object_id"
    
    add_foreign_key "groups", "actors", :name => "groups_on_actor_id"
    
    add_foreign_key "posts", "activity_objects", :name => "posts_on_activity_object_id"
    
    add_foreign_key "profiles", "actors", :name => "profiles_on_actor_id"
    
    add_foreign_key "relation_permissions", "relations", :name => "relation_permissions_on_relation_id"
    add_foreign_key "relation_permissions", "permissions", :name => "relation_permissions_on_permission_id"
    
    add_foreign_key "relations", "spheres", :name => "relations_on_sphere_id"

    add_foreign_key "spheres", "actors", :name => "spheres_on_actor_id"

    add_foreign_key "tie_activities", "ties",       :name => "tie_activities_on_tie_id"
    add_foreign_key "tie_activities", "activities", :name => "tie_activities_on_activity_id"
    
    add_foreign_key "ties", "actors", :name => "ties_on_receiver_id", :column => "receiver_id"
    add_foreign_key "ties", "actors", :name => "ties_on_relation_id", :column => "sender_id"
    add_foreign_key "ties", "relations", :name => "ties_on_sender_id"
    
    add_foreign_key "users", "actors", :name => "users_on_actor_id"
  end
  
  
  def self.down
    remove_foreign_key "activities", :name => "index_activities_on_activity_verb_id"
    
    remove_foreign_key "activity_object_activities", :name => "index_activity_object_activities_on_activity_id"
    remove_foreign_key "activity_object_activities", :name => "activity_object_activities_on_activity_object_id"
    
    remove_foreign_key "actors", :name => "actors_on_activity_object_id"
    
    remove_foreign_key "authentications", :name => "authentications_on_user_id"

    remove_foreign_key "avatars", :name => "avatars_on_actor_id"
    
    remove_foreign_key "comments", :name => "comments_on_activity_object_id"
    
    remove_foreign_key "groups", :name => "groups_on_actor_id"
       
    remove_foreign_key "posts", :name => "posts_on_activity_object_id"
    
    remove_foreign_key "profiles", :name => "profiles_on_actor_id"
    
    remove_foreign_key "relation_permissions", :name => "relation_permissions_on_relation_id"
    remove_foreign_key "relation_permissions", :name => "relation_permissions_on_permission_id"

    remove_foreign_key "relations", :name => "relations_on_sphere_id"

    remove_foreign_key "spheres", :name => "spheres_on_actor_id"
    
    remove_foreign_key "tie_activities", :name => "tie_activities_on_tie_id"
    remove_foreign_key "tie_activities", :name => "tie_activities_on_activity_id"
    
    remove_foreign_key "ties", :name => "ties_on_receiver_id", :column => "receiver_id"
    remove_foreign_key "ties", :name => "ties_on_relation_id", :column => "sender_id"
    remove_foreign_key "ties", :name => "ties_on_sender_id"
    
    remove_foreign_key "users", :name => "users_on_actor_id"
    
    drop_table :activities
    drop_table :activity_object_activities
    drop_table :activity_objects
    drop_table :activity_verbs
    drop_table :actors
    drop_table :authentications
    drop_table :avatars
    drop_table :comments
    drop_table :groups
    drop_table :permissions
    drop_table :posts
    drop_table :profiles
    drop_table :relation_permissions
    drop_table :relations
    drop_table :spheres
    drop_table :ties
    drop_table :users
  end
end
