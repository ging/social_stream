# This relation model implements Twitter-like relations:
# Users just have followers and followings.
#
# Use this model setting <tt>config.relation_model = :follow</tt> in your
# <tt>config/initializers/social_stream.rb</tt>
class Relation::Follow < Relation::Single
  PERMISSIONS = 
    [
      [ 'create', 'activity' ],
      [ 'read',   'activity' ],
      [ 'follow', nil ]
    ]
end
