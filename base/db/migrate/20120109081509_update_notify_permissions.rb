# Before the 'notify' permission was added, only users with the first relation in each group where notified by email
# This migration preserves the old behavior by granting the 'notify' permission to the first relation in each group
class UpdateNotifyPermissions < ActiveRecord::Migration
  def up
    # Save record_timestamp, set to false
    r_ts = RelationPermission.record_timestamps
    RelationPermission.record_timestamps = false

    # INSERT INTO permission_relation
    perm_notify = Permission.where(:action => 'notify')[0]
    if perm_notify.nil?
      perm_notify = Permission.create(:action => 'notify')
    end
    Relation.where(:sender_type => 'Group', :type => 'Relation::Custom').group('actor_id').each do |r|
      RelationPermission.create do |rp|
        rp.relation = r
	rp.permission = perm_notify
      end
    end

    # Recover record_timestamps
    RelationPermission.record_timestamps = r_ts
  end

  def down
  end
end
