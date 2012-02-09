class LinkserGroupTitleAndDescriptionInActivityObject < ActiveRecord::Migration
  def up
    # Fix 'links' table
    Link.all.each do |l|
      l.activity_object.title = l.title
      l.activity_object.description = l.description
      l.save!
    end
    change_table :links do |t|
      t.remove :title
      t.remove :description
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Due to trans-gem oddities
  end
end
