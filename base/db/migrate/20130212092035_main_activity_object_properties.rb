class MainActivityObjectProperties < ActiveRecord::Migration
  def up
    add_column :activity_object_properties, :main, :boolean
    
    ActivityObjectProperty.reset_column_information

    # TODO migration
  end
end
