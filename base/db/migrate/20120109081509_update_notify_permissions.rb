# Before the 'notify' permission was added, only users with the first relation in each group where notified by email
# This migration preserves the old behavior by granting the 'notify' permission to the first relation in each group
class UpdateNotifyPermissions < ActiveRecord::Migration
  def up
    # Save record_timestamp, set to false
    r_ts = RelationPermission.record_timestamps
    RelationPermission.record_timestamps = false

    # Make sure 'notify' exists
    perm_notify = Permission.where(:action => 'notify')[0]
    if perm_notify.nil?
      perm_notify = Permission.create(:action => 'notify')
    end

    seen_actors=[]
    Relation.where(:sender_type => 'Group', :type => 'Relation::Custom').each do |r|
      next if seen_actors.include? r.actor
      seen_actors << r.actor
      # INSERT INTO permission_relations
      RelationPermission.create do |rp|
        rp.relation = r
	rp.permission = perm_notify
	rp.created_at = r.created_at
	rp.updated_at = r.updated_at
      end
    end

    # Recover record_timestamps
    RelationPermission.record_timestamps = r_ts
  end

  def down
  end
end
