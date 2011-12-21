class RoomsController < InheritedResources::Base
  actions :create, :destroy

  respond_to :js

  load_and_authorize_resource
end
