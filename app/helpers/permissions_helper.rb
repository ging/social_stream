module PermissionsHelper
  DEFAULT_PERMISSIONS =
    [
      [ "read",    "activity" ],
      [ "create",  "activity" ],
      [ "follow", nil ],
      [ "represent", nil ]
    ]

  def default_permissions
    @default_permissions ||=
      DEFAULT_PERMISSIONS.map{ |p|
        Permission.find_or_create_by_action_and_object *p
      }
  end
end
