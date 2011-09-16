class RemoveSpheres < ActiveRecord::Migration
  def up
    remove_foreign_key "relations", :name => "relations_on_sphere_id"

    remove_foreign_key "spheres", :name => "spheres_on_actor_id"

    remove_column :relations, :sphere_id

    drop_table :spheres
  end

  def down
    add_column :relations, :sphere_id, :integer

    add_index "relations", "sphere_id"

    create_table "spheres", :force => true do |t|
      t.string   "name"
      t.integer  "actor_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "spheres", "actor_id"

    add_foreign_key "relations", "spheres", :name => "relations_on_sphere_id"

    add_foreign_key "spheres", "actors", :name => "spheres_on_actor_id"
  end
end
