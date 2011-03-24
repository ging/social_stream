class TiesController < InheritedResources::Base
  respond_to :html, :xml, :js

  before_filter :authenticate_user!, :only => :suggestion

  def suggestion
    @tie = current_subject.suggestion
    render :layout  => false
  end
  
  def create
      super do |format|
        format.html { redirect_to resource.receiver_subject }
      end
  end
  
end
