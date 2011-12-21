class AddLanguageField < ActiveRecord::Migration
  def self.up
    change_table "users" do |t|
      t.string "language", :default => "en"
    end
  end

  def self.down
    change_table :users do |t|
      t.remove "language"
    end
  end
end
