class PrivaciesController < ApplicationController
  respond_to :html , :js
  
  def show

  end
  
  def levels
    render :layout=>false 
  end
  
  def permissions
    render :layout=>false 
  end
  
  def create
    #Save privacy rules
    flash[:notice] = "Privacy rules saved"
    redirect_to users_path
  end
  
end