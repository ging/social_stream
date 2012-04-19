# This migration comes from social_stream_base_engine (originally 20120403175913)
class CreateActivityObjectAudiences < ActiveRecord::Migration
  def change
    create_table :activity_object_audiences do |t|
      t.references :activity_object
      t.references :relation

      t.timestamps
    end

    add_foreign_key :activity_object_audiences, :activity_objects, :name => 'activity_object_audiences_on_activity_object_id'
    add_foreign_key :activity_object_audiences, :relations, :name => 'activity_object_audiences_on_relation_id'


    ActivityObject.all.each do |ao|
      post_activity = ao.post_activity
      next if post_activity.blank?

      ao.relation_ids = post_activity.relation_ids
    end

    ActivityObjectAudience.record_timestamps = false

    ActivityObject.all.each do |ao|
      ao.activity_object_audiences.each do |aud|
        aud.created_at = aud.updated_at = ao.created_at
        aud.save!
      end
    end

    ActivityObjectAudience.record_timestamps = true
    ActivityObject.reset_column_information
  end
end
