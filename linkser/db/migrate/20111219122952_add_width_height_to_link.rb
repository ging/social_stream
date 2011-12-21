class AddWidthHeightToLink < ActiveRecord::Migration
  def self.up
    change_table "links" do |t|
      t.integer "width",  :default => 470
      t.integer "height", :default => 353
    end
  end

  def self.down
    change_table :links do |t|
      t.remove "width"
      t.remove "height"
    end
  end
end
