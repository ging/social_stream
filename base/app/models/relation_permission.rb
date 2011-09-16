class RelationPermission < ActiveRecord::Base
  belongs_to :relation
  belongs_to :permission
end
