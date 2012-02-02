class SingletonSingleRelations < ActiveRecord::Migration
  def up
    r_new = Relation::Public.create!
    Relation.find_all_by_type('Relation::Public').each do |r|
      next if r == r_new

      # Reassign r -> r_new
      Tie.find_all_by_relation_id(r.id).each do |t|
        t.update_column(:relation_id, r_new.id)
      end
      Audience.find_all_by_relation_id(r.id).each do |a|
        a.update_column(:relation_id, r_new.id)
      end

      # Delete r
      r.delete
    end

    r_new = Relation::Reject.create!
    Relation.find_all_by_type('Relation::Reject').each do |r|
      next if r == r_new

      # Reassign r -> r_new
      Tie.find_all_by_relation_id(r.id).each do |t|
        t.update_column(:relation_id, r_new.id)
      end
      Audience.find_all_by_relation_id(r.id).each do |a|
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
