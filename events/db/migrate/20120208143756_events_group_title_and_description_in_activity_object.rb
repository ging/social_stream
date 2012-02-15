class EventsGroupTitleAndDescriptionInActivityObject < ActiveRecord::Migration
  def up
    ao_ts = ActivityObject.record_timestamps
    ActivityObject.record_timestamps = false

    # Fix 'events' table
    e_ts = Event.record_timestamps
    Event.record_timestamps = false

    Event.all.each do |e|
      e.activity_object.title = e.read_attribute(:title)
      e.save!
    end
    change_table :events do |t|
      t.remove :title
    end
    Event.reset_column_information
    Event.record_timestamps = e_ts

    ActivityObject.record_timestamps = ao_ts
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Due to trans-gem oddities
  end
end
