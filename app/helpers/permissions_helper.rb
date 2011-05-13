module PermissionsHelper
  DEFAULT_PERMISSIONS =
    [
      [ "read",    "activity", "weak_star_ties" ],
      [ "create",  "activity", nil ],
      [ "follow", nil, nil],
      [ "represent", nil, nil]
    ]

  def default_permissions
    @default_permissions ||=
      DEFAULT_PERMISSIONS.map{ |p|
        Permission.find_or_create_by_action_and_object_and_function *p
      }
  end
end
