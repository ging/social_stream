module PermissionsHelper
  DEFAULT_PERMISSIONS =
    [
      [ "read",    "activity", "star_ties" ],
      [ "create",  "activity", nil ],
      [ "destroy", "activity", nil ]
    ]

  def default_permissions
    DEFAULT_PERMISSIONS.map{ |p|
      Permission.find_by_action_and_object_and_function *p
    }
  end
end
