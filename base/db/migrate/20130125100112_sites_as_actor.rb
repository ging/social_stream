class SitesAsActor < ActiveRecord::Migration
  def change
    add_column :sites, :type, :string
    add_column :sites, :actor_id, :integer

    add_index :sites, :actor_id, name: 'index_sites_on_actor_id'

    add_foreign_key :sites, :actors, name: 'index_sites_on_actor_id'
  end
end
