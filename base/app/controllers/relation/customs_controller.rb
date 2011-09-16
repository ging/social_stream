class Relation::CustomsController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource :class => Relation::Custom

  respond_to :html, :js
end
