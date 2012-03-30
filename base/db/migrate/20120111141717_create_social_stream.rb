class CreateSocialStream < ActiveRecord::Migration
  def change
    create_table "activities", :force => true do |t|
      t.integer  "activity_verb_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "ancestry"
      t.integer  "channel_id"
    end

    add_index "activities", ["activity_verb_id"], :name => "index_activities_on_activity_verb_id"
    add_index "activities", ["channel_id"], :name => "index_activities_on_channel_id"

    create_table "activity_object_activities", :force => true do |t|
      t.integer  "activity_id"
      t.integer  "activity_object_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "object_type"
    end

    add_index "activity_object_activities", ["activity_id"], :name => "index_activity_object_activities_on_activity_id"
    add_index "activity_object_activities", ["activity_object_id"], :name => "index_activity_object_activities_on_activity_object_id"

    create_table "activity_objects", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "object_type", :limit => 45
      t.integer  "like_count",                :default => 0
      t.integer  "channel_id"
    end

    add_index "activity_objects", ["channel_id"], :name => "index_activity_objects_on_channel_id"

    create_table "activity_verbs", :force => true do |t|
      t.string   "name",       :limit => 45
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "actors", :force => true do |t|
      t.string   "name"
      t.string   "email",              :default => "",   :null => false
      t.string   "slug"
      t.string   "subject_type"
      t.boolean  "notify_by_email",    :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "activity_object_id"
      t.integer  "follower_count",     :default => 0
    end

    add_index "actors", ["activity_object_id"], :name => "index_actors_on_activity_object_id"
    add_index "actors", ["email"], :name => "index_actors_on_email"
    add_index "actors", ["slug"], :name => "index_actors_on_slug", :unique => true

    create_table "audiences", :force => true do |t|
      t.integer "relation_id"
      t.integer "activity_id"
    end

    add_index "audiences", ["activity_id"], :name => "index_audiences_on_activity_id"
    add_index "audiences", ["relation_id"], :name => "index_audiences_on_relation_id"

    create_table "authentications", :force => true do |t|
      t.integer  "user_id"
      t.string   "provider"
      t.string   "uid"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

    create_table "avatars", :force => true do |t|
      t.integer  "actor_id"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.boolean  "active",            :default => true
    end

    add_index "avatars", ["actor_id"], :name => "index_avatars_on_actor_id"

    create_table "channels", :force => true do |t|
      t.integer  "author_id"
      t.integer  "owner_id"
      t.integer  "user_author_id"
      t.datetime "created_at",     :null => false
      t.datetime "updated_at",     :null => false
    end

    add_index "channels", ["author_id"], :name => "index_channels_on_author_id"
    add_index "channels", ["owner_id"], :name => "index_channels_on_owner_id"
    add_index "channels", ["user_author_id"], :name => "index_channels_on_user_author_id"

    create_table "comments", :force => true do |t|
      t.integer  "activity_object_id"
      t.text     "text"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "comments", ["activity_object_id"], :name => "index_comments_on_activity_object_id"

    create_table "contacts", :force => true do |t|
      t.integer  "sender_id"
      t.integer  "receiver_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "inverse_id"
      t.integer  "ties_count",  :default => 0
    end

    add_index "contacts", ["inverse_id"], :name => "index_contacts_on_inverse_id"
    add_index "contacts", ["receiver_id"], :name => "index_contacts_on_receiver_id"
    add_index "contacts", ["sender_id"], :name => "index_contacts_on_sender_id"

    create_table "groups", :force => true do |t|
      t.integer  "actor_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "groups", ["actor_id"], :name => "index_groups_on_actor_id"

    create_table "permissions", :force => true do |t|
      t.string   "action"
      t.string   "object"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "posts", :force => true do |t|
      t.integer  "activity_object_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "text"
    end

    add_index "posts", ["activity_object_id"], :name => "index_posts_on_activity_object_id"

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

    add_index "profiles", ["actor_id"], :name => "index_profiles_on_actor_id"

    create_table "relation_permissions", :force => true do |t|
      t.integer  "relation_id"
      t.integer  "permission_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "relation_permissions", ["permission_id"], :name => "index_relation_permissions_on_permission_id"
    add_index "relation_permissions", ["relation_id"], :name => "index_relation_permissions_on_relation_id"

    create_table "relations", :force => true do |t|
      t.integer  "actor_id"
      t.string   "type"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "sender_type"
      t.string   "receiver_type"
      t.string   "ancestry"
    end

    add_index "relations", ["actor_id"], :name => "index_relations_on_actor_id"
    add_index "relations", ["ancestry"], :name => "index_relations_on_ancestry"

    create_table "ties", :force => true do |t|
      t.integer  "contact_id"
      t.integer  "relation_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "ties", ["contact_id"], :name => "index_ties_on_contact_id"
    add_index "ties", ["relation_id"], :name => "index_ties_on_relation_id"

    create_table "users", :force => true do |t|
      t.string   "encrypted_password",     :limit => 128, :default => "",     :null => false
      t.string   "password_salt"
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",                         :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.string   "authentication_token"
      t.datetime "created_at",                                                :null => false
      t.datetime "updated_at",                                                :null => false
      t.integer  "actor_id"
      t.string   "language"
    end

    add_index "users", ["actor_id"], :name => "index_users_on_actor_id"
    add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

    add_foreign_key "activities", "activity_verbs", :name => "index_activities_on_activity_verb_id"
    add_foreign_key "activities", "channels", :name => "index_activities_on_channel_id"

    add_foreign_key "activity_object_activities", "activities", :name => "index_activity_object_activities_on_activity_id"
    add_foreign_key "activity_object_activities", "activity_objects", :name => "activity_object_activities_on_activity_object_id"

    add_foreign_key "activity_objects", "channels", :name => "index_activity_objects_on_channel_id"

    add_foreign_key "actors", "activity_objects", :name => "actors_on_activity_object_id"

    add_foreign_key "audiences", "activities", :name => "audiences_on_activity_id"
    add_foreign_key "audiences", "relations", :name => "audiences_on_relation_id"

    add_foreign_key "authentications", "users", :name => "authentications_on_user_id"

    add_foreign_key "avatars", "actors", :name => "avatars_on_actor_id"

    add_foreign_key "channels", "actors", :name => "index_channels_on_author_id", :column => "author_id"
    add_foreign_key "channels", "actors", :name => "index_channels_on_owner_id", :column => "owner_id"
    add_foreign_key "channels", "actors", :name => "index_channels_on_user_author_id", :column => "user_author_id"

    add_foreign_key "comments", "activity_objects", :name => "comments_on_activity_object_id"

    add_foreign_key "contacts", "actors", :name => "contacts_on_receiver_id", :column => "receiver_id"
    add_foreign_key "contacts", "actors", :name => "contacts_on_sender_id", :column => "sender_id"

    add_foreign_key "groups", "actors", :name => "groups_on_actor_id"

    add_foreign_key "posts", "activity_objects", :name => "posts_on_activity_object_id"

    add_foreign_key "profiles", "actors", :name => "profiles_on_actor_id"

    add_foreign_key "relation_permissions", "permissions", :name => "relation_permissions_on_permission_id"
    add_foreign_key "relation_permissions", "relations", :name => "relation_permissions_on_relation_id"

    add_foreign_key "relations", "actors", :name => "relations_on_actor_id"

    add_foreign_key "ties", "contacts", :name => "ties_on_contact_id"
    add_foreign_key "ties", "relations", :name => "ties_on_relation_id"

    add_foreign_key "users", "actors", :name => "users_on_actor_id"
  end
end
