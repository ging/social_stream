class MainActivityObjectProperties < ActiveRecord::Migration
  class APMigration < ActiveRecord::Base
    self.table_name = 'activity_object_properties'
    self.record_timestamps = false
    self.inheritance_column = "other"
  end

  def up
    add_column :activity_object_properties, :main, :boolean
    
    ActivityObjectProperty.reset_column_information

    APMigration.where(type: 'ActivityObjectProperty::Poster').all.each do |a|
      a.update_attributes! main: true,
                           type: nil
    end
  end
end
