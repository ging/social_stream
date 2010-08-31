class Permission < ActiveRecord::Base
  has_many :relation_permissions
  has_many :relations

end
