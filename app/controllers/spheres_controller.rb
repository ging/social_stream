class SpheresController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html, :js

  protected

  def begin_of_association_chain
    current_subject
  end
end
