class SiteClientAdminToManager < ActiveRecord::Migration

  class Relation::Admin < Relation; end

  def up
    admin = Relation::Admin.first

    if admin.present?
      rt = Tie.record_timestamps
      Tie.record_timestamps = false

      admin.ties.each do |t|
        t.relation = Relation::Manager.instance
        t.save!
      end

      Tie.record_timestamps = rt
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
