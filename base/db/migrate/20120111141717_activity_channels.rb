class ActivityChannels < ActiveRecord::Migration
  class ActivityMigration < ActiveRecord::Base
    self.record_timestamps = false
    set_table_name "activities"
  end

  def up
    change_table :activities do |t|
      t.integer :channel_id
    end

    add_index "activities", "channel_id"

    add_foreign_key "activities", "channels", :name => "index_activities_on_channel_id"

    ActivityMigration.reset_column_information

    ActivityObject.all.each do |a|
      activity = Activity.find(a.id)

      case activity.verb

      when "post", "update"
        a.channel_id = activity.direct_object.channel_id
      else
        contact = Contact.find activity.contact_id

        author_id = contact.sender_id
        owner_id  = contact.receiver_id

        user_author_id =
         (contact.sender_subject.is_a?(User) ?
          contact.sender :
          contact.sender.sent_ties.order(:created_at).first.receiver).id

        a.channel_id =
          Channel.find_or_create_by_author_id_and_user_author_id_and_owner_id(author_id,
                                                                              user_author_id,
                                                                              owner_id).id
      end

      a.save!
    end

    remove_foreign_key "activities", :name => "index_activity_objects_on_contact_id"

    remove_column :activities, :contact_id

    Activity.reset_column_information
  end

  def down
    change_table :activities do |t|
      t.integer :contact_id
    end

    add_index "activities", "contact_id"

    add_foreign_key "activities", "contacts", :name => "index_activities_on_contact_id"

    ActivityMigration.reset_column_information

    ActivityMigration.all.each do |a|
      channel = Channel.find a.channel_id
      a.contact_id = Contact.find_by_sender_id_and_receiver_id(channel.author_id, channel.owner_id)

      a.save!
    end

    remove_foreign_key "activities", :name => "index_activities_on_channel_id"

    remove_column :activities, :channel_id
  end
end
