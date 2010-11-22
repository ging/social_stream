class TiesController < InheritedResources::Base
  respond_to :html, :xml, :js

  before_filter :authenticate_user!, :only => :suggestion

  def suggestion
    @tie = current_user.suggestion
    render :layout  => false
  end
end
