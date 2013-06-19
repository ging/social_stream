class SiteClientAdminToCustom < ActiveRecord::Migration

  class Relation::Admin < Relation; end

  def up
    Site::Client.all.each do |c|
      Relation::Custom.defaults_for c.actor
    end

    admin = Relation::Admin.first

    if admin.present?
      rt = Tie.record_timestamps
      Tie.record_timestamps = false

      admin.ties.each do |t|
        t.relation = t.sender.relation_customs.sort.first
        t.save!
      end

      Tie.record_timestamps = rt
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
