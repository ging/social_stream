class PermissionsController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :js

  actions :index

  belongs_to :relation
end
