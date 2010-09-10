class CreateSpaces < ActiveRecord::Migration
  def self.up
    create_table :spaces do |t|
      t.references :actor
      t.timestamps
    end
  end

  def self.down
    drop_table :spaces
  end
end
