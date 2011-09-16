class PermissionsController < InheritedResources::Base
  before_filter :authenticate_user!

  respond_to :js

  actions :index

  belongs_to :relation

  def index
    authorize! :read, parent

    index!
  end
end
