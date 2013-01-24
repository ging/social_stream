class CreateSocialStreamPlaces < ActiveRecord::Migration
  def change

    create_table "geotags", :force => true do |t|
      t.integer  "activity_object_id"
      t.integer  "address_id"
      t.float    "latitude"
      t.float    "longitude"
      t.float    "altitude"
      t.float    "heading"
      t.float    "tilt"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index :geotags, [:latitude, :longitude]

    create_table "places", :force => true do |t|
      t.integer  "activity_object_id"
      t.string   "url"
      t.string   "phone_number"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "places", ["activity_object_id"], :name => "index_places_on_activity_object_id"    

    create_table "addresses", :force => true do |t|
      t.string   "formatted"
      t.string   "streetAddress"
      t.string   "locality"
      t.string   "region"
      t.string   "postalCode"
      t.string   "country"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "addresses", ["streetAddress", "locality"], :name => "index_addresses_on_streetAddress_and_locality"

  end
end
