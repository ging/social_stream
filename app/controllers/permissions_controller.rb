class PermissionsController < InheritedResources::Base
  respond_to :js

  actions :index

  belongs_to :relation
end
