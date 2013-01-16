class CreateSocialStreamPlaces < ActiveRecord::Migration
  def change

    create_table "places", :force => true do |t|
      t.integer  "activity_object_id"
      t.integer  "address_id"
      t.string   "url"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.float    "latitude"
      t.float    "longitude"
      t.string   "phone_number"
    end

    add_index "places", ["activity_object_id"], :name => "index_places_on_activity_object_id"
    add_index "places", ["address_id"], :name => "index_places_on_address_id"
    add_index "places", ["latitude", "longitude"], :name => "index_places_on_latitude_and_longitude"
    

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


    add_foreign_key "places", "activity_objects", :name => "places_on_activity_object_id"
    add_foreign_key "places", "addresses", :name => "places_on_address_id"

  end
end
