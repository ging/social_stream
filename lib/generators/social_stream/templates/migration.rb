class CreateSocialStream < ActiveRecord::Migration
  def self.up
    create_table "activities", :force => true do |t|
      t.integer  "activity_verb_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "parent_id"
      t.integer  "tie_id"
    end

    add_index "activities", ["activity_verb_id"], :name => "fk_activity_verb"
    add_index "activities", ["tie_id"], :name => "fk_activities_tie"

    create_table "activity_object_activities", :force => true do |t|
      t.integer  "activity_id"
      t.integer  "activity_object_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "type",               :limit => 45
    end

    add_index "activity_object_activities", ["activity_id"], :name => "fk_activity_object_activities_1"
    add_index "activity_object_activities", ["activity_object_id"], :name => "fk_activity_object_activities_2"

    create_table "activity_objects", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "object_type", :limit => 45
    end

    create_table "activity_verbs", :force => true do |t|
      t.string   "name",       :limit => 45
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "actors", :force => true do |t|
      t.string   "name",               :limit => 45
      t.string   "email",                            :default => "", :null => false
      t.string   "permalink",          :limit => 45
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "activity_object_id"
    end

    add_index "actors", ["activity_object_id"], :name => "fk_actors_activity_object"
    add_index "actors", ["email"], :name => "index_actors_on_email"
    add_index "actors", ["permalink"], :name => "index_actors_on_permalink", :unique => true

    create_table "permissions", :force => true do |t|
      t.string   "action"
      t.string   "object"
      t.string   "parameter"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "relation_permissions", :force => true do |t|
      t.integer  "relation_id"
      t.integer  "permission_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "relation_id"
    end

    add_index "relation_permissions", ["relation_id"], :name => "fk_relation_permissions_relation"
    add_index "relation_permissions", ["permission_id"], :name => "fk_relation_permissions_permission"

    create_table "relations", :force => true do |t|
      t.string   "name",       :limit => 45
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "sender_type"
      t.string   "receiver_type"
      t.string   "ancestry"
    end

    add_index "relations", ["ancestry"]

    create_table "tags", :force => true do |t|
      t.string   "name",       :limit => 45
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tags_activity_objects", :force => true do |t|
      t.integer "tag_id"
      t.integer "activity_object_id"
    end

    add_index "tags_activity_objects", ["activity_object_id"], :name => "fk_tags_activity_objects_2"
    add_index "tags_activity_objects", ["tag_id"], :name => "fk_tags_activity_objects_1"

    create_table "ties", :force => true do |t|
      t.integer  "sender_id"
      t.integer  "receiver_id"
      t.integer  "relation_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "ties", ["receiver_id"], :name => "fk_tie_receiver"
    add_index "ties", ["relation_id"], :name => "fk_tie_relation"
    add_index "ties", ["sender_id"], :name => "fk_tie_sender"
  end

  def self.down
  end
end
