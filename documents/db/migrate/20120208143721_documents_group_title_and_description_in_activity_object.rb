class DocumentsGroupTitleAndDescriptionInActivityObject < ActiveRecord::Migration
  def up
    ao_ts = ActivityObject.record_timestamps
    ActivityObject.record_timestamps = false

    # Fix 'documents' table
    d_ts = Document.record_timestamps
    Document.record_timestamps = false

    Document.all.each do |d|
      d.activity_object.title = d.read_attribute(:title)
      d.activity_object.description = d.read_attribute(:description)
      d.save!
    end
    change_table :documents do |t|
      t.remove :title
      t.remove :description
    end
    Document.reset_column_information
    Document.record_timestamps = d_ts

    ActivityObject.record_timestamps = ao_ts
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Due to trans-gem oddities
  end
end
