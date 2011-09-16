class RemovePermissionFunction < ActiveRecord::Migration
  def up
    remove_column :permissions, :function

    ts = RelationPermission.record_timestamps
    RelationPermission.record_timestamps = false

    Permission.all.each do |p|
      q = Permission.find_by_action_and_object p.action, p.object

      next if p == q

      p.relation_permissions.each do |rp|
        rp.update_attribute :permission_id, q.id
      end

      p.reload.destroy
    end

    RelationPermission.record_timestamps = ts
  end

  def down
    add_column :permissions, :function, :string
  end
end
