class Relation::CustomsController < InheritedResources::Base
  respond_to :js

  belongs_to :sphere, :optional => true
end
