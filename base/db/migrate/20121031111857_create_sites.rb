class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.text :config

      t.timestamps
    end
  end
end
