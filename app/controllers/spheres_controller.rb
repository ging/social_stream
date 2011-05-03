class SpheresController < InheritedResources::Base
  respond_to :html, :js

  protected

  def begin_of_association_chain
    current_subject
  end
end
