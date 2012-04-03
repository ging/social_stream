class RelationPublicPermissions < ActiveRecord::Migration
  def up
    Relation::Public.instance.permissions = Relation::Public.permissions if Relation::Public.instance.permissions.blank?
  end

  def down
  end
end
