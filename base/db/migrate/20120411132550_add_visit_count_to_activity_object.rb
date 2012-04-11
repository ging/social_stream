class AddVisitCountToActivityObject < ActiveRecord::Migration
  def up
    add_column :activity_objects, :visit_count, :integer, :default => 0
  end

  def down
    remove_column :activity_objects, :visit_count
  end
end
