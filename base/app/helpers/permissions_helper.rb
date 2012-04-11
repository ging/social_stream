module PermissionsHelper
  DEFAULT_PERMISSIONS =
    [
      [ "read",    "activity" ],
      [ "create",  "activity" ],
      [ "follow", nil ],
      [ "represent", nil ],
      [ "notify", nil ]
    ]

  def default_permissions
    @default_permissions ||=
      DEFAULT_PERMISSIONS.map{ |p|
        Permission.find_or_create_by_action_and_object *p
      }
  end

  def disable_permission_edit? perm
    (perm.action == 'represent') and (@relation.ties.size > 0) and perm.relations.include?(@relation) and (perm.relations.where(:actor_id => @relation.actor_id).find_all{|r| r.ties.size > 0}.size <= 1)
  end
end
