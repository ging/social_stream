# This relation model implements Twitter-like relations:
# Users just have followers and followings.
#
# You can achieve a Twitter-like model for users
# setting custom relations to empty and system relations to [ :follow ]
# in config/initializers/social_stream.rb
#
#   config.custom_relations[:user] = {}
#
#   config.system_relations[:user] = [ :follow ]
#
class Relation::Follow < Relation::Single
  PERMISSIONS = 
    [
      [ 'create', 'activity' ],
      [ 'read',   'activity' ],
      [ 'follow', nil ]
    ]
end
