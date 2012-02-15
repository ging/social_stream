class LinkserGroupTitleAndDescriptionInActivityObject < ActiveRecord::Migration
  def up
    ao_ts = ActivityObject.record_timestamps
    ActivityObject.record_timestamps = false

    # Fix 'links' table
    l_ts = Link.record_timestamps
    Link.record_timestamps = false

    Link.all.each do |l|
      l.activity_object.title = l.read_attribute(:title)
      l.activity_object.description = l.read_attribute(:description)
      l.save!
    end

    change_table :links do |t|
      t.remove :title
      t.remove :description
    end

    Link.reset_column_information
    Link.record_timestamps = l_ts

    ActivityObject.record_timestamps = ao_ts
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Due to trans-gem oddities
  end
end
