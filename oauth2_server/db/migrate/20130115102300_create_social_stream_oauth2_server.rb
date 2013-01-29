class CreateSocialStreamOauth2Server < ActiveRecord::Migration
  def change
    create_table :oauth2_tokens do |t|
      t.string :type

      t.integer :user_id
      t.integer :site_id
      t.string  :token

      t.string  :redirect_uri
      t.integer :refresh_token_id

      t.timestamps
      t.datetime :expires_at
    end

    add_index "oauth2_tokens", :user_id, :name => "index_oauth2_tokens_on_user_id"
    add_index "oauth2_tokens", :site_id, :name => "index_oauth2_tokens_on_site_id"
    add_index "oauth2_tokens", :token,   :name => "index_oauth2_tokens_on_token"
    add_index "oauth2_tokens", :refresh_token_id, :name => "index_oauth2_tokens_on_refresh_token_id"

    add_foreign_key "oauth2_tokens", "sites", :name => "index_oauth2_tokens_on_site_id"
    add_foreign_key "oauth2_tokens", "users", :name => "index_oauth2_tokens_on_user_id"
  end
end
