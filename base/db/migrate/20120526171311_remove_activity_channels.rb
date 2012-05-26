class RemoveActivityChannels < ActiveRecord::Migration
  class Channel < ActiveRecord::Base; end

  def up
    change_table :activities do |t|
      t.references :author
      t.references :user_author
      t.references :owner
    end

    Activity.record_timestamps = false
    Activity.reset_column_information

    Activity.all.each do |a|
      c = Channel.find a.channel_id
      %w{ author_id user_author_id owner_id }.each do |m|
        a.__send__ "#{ m }=", c.__send__(m) # a.author_id = c.author_id
      end
      a.save!
    end

    Activity.record_timestamps = true

    remove_column :activities, :channel_id

    Activity.reset_column_information

    drop_table :channels
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
