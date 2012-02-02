class SingletonSingleRelations < ActiveRecord::Migration
  def up
    Tie.record_timestamps = false
    Audience.record_timestamps = false

    r_new = Relation::Public.instance

    Relation::Public.all.each do |r|
      next if r == r_new

      # Reassign r -> r_new
      r.ties.each do |t|
        t.update_column(:relation_id, r_new.id)
      end

      r.audiences.each do |a|
        a.update_column(:relation_id, r_new.id)
      end

      # Delete r
      r.delete
    end

    r_new = Relation::Reject.instance

    Relation::Reject.all.each do |r|
      next if r == r_new

      # Reassign r -> r_new
      r.ties.each do |t|
        t.update_column(:relation_id, r_new.id)
      end

      r.audiences.each do |a|
        a.update_column(:relation_id, r_new.id)
      end

      # Delete r
      r.delete
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
