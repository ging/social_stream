# Before the 'notify' permission was added, only users with the first relation in each group where notified by email
# This migration preserves the old behavior by granting the 'notify' permission to the first relation in each group
class UpdateNotifyPermissions < ActiveRecord::Migration
  def up
    perm_notify = Permission.find_or_create_by_action('notify')
    Group.all.each do |g|
      r = g.relation_customs.first
      next if r.blank?
      r.permissions << perm_notify
    end
  end

  def down
  end
end
