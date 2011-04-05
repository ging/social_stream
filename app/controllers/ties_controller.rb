class TiesController < InheritedResources::Base
  respond_to :html, :xml, :js

  before_filter :authenticate_user!

  def create
    create! do |format|
      format.html { redirect_to resource.receiver_subject }
    end
  end

  def update
    update do |format|
      format.html { redirect_to resource.receiver_subject }
    end
  end

  def suggestion
    @tie = current_subject.suggestion
    render :layout  => false
  end
end
