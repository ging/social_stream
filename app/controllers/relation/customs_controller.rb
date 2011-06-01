class Relation::CustomsController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource :class => Relation::Custom

  respond_to :js

  belongs_to :sphere, :optional => true

  def index
    # Must authorize index, because Cancan does not filter collection with conditions.
    # See https://github.com/ryanb/cancan/wiki/checking-abilities
    authorize! :read, parent.customs.new

    index!
  end
end
