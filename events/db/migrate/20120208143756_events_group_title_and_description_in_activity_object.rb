class EventsGroupTitleAndDescriptionInActivityObject < ActiveRecord::Migration
  def up
    ActivityObject.record_timestamps = false

    # Fix 'events' table
    Event.record_timestamps = false
    Event.all.each do |e|
      e.activity_object.title = e.title
      e.activity_object.description = ''
      e.save!
    end
    change_table :events do |t|
      t.remove :title
    end
    Event.reset_column_information
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Due to trans-gem oddities
  end
end
