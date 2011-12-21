class AddScheduler < ActiveRecord::Migration

  class EventSchedulerMigration < ActiveRecord::Base
    self.record_timestamps = false
    set_table_name "events"
  end

  def up
    change_table :events do |t|
      t.date     :start_date
      t.date     :end_date
      t.integer  :frequency, :default => 0
      t.integer  :interval
      t.integer  :interval_flag, :default => 0
    end

    EventSchedulerMigration.all.each do |e|
      e.start_date = e.start_at
      e.end_date   = e.end_at
      e.save!
    end
  end

  def down
    change_table :events do |t|
      t.remove :start_date
      t.remove :end_date
      t.remove :frequency
      t.remove :interval
      t.remove :interval_flag
    end
  end
end
