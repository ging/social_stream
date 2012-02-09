class LinkserGroupTitleAndDescriptionInActivityObject < ActiveRecord::Migration
  def up
    ActivityObject.record_timestamps = false

    # Fix 'links' table
    Link.record_timestamps = false
    Link.all.each do |l|
      l.activity_object.title = l.title
      l.activity_object.description = l.description
      l.save!
    end
    change_table :links do |t|
      t.remove :title
      t.remove :description
    end
    Link.reset_column_information
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Due to trans-gem oddities
  end
end
