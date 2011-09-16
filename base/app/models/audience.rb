# Every {Activity} is shared with one or more {audiences Audience}.
#
# Each {Audience} is equivalent to a {Relation}, which defines the {actors Actor}
# that are assigned to that relation and the {permissions Permission} granted to
# that {Audience}
class Audience < ActiveRecord::Base
  belongs_to :activity
  belongs_to :relation
end
