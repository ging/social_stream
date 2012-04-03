# Every {ActivityObject} ({Post}, {Comment}, etc.) is shared with one or more {Relation Relations}.
#
# Each {Relation} is equivalent to a set {Actor Actors}, which are the ones that have {Tie Ties}
# to that {Relation}, in other words, the contacts that were added to that {Relation}
class ActivityObjectAudience < ActiveRecord::Base
  belongs_to :activity_object
  belongs_to :relation
end
