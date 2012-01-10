class DocumentObjectType < ActiveRecord::Migration
  class ActivityObjectMigration < ActiveRecord::Base
    self.record_timestamps = false
    set_table_name "activity_objects"
  end

  def up
    ActivityObjectMigration.where(:object_type => %w( Picture Audio Video )).each do |a|
      a.update_attribute! :object_type, "Document"
    end
  end

  def down
  end
end
