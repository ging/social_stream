class ApiController < ApplicationController
  
  def create_key
    current_user.reset_authentication_token!
    redirect_to :controller => :users, :action => :show, :id => current_user.permalink
  end
  
  def users
    if !params[:id]
      params[:id]=current_user.permalink
    end
    
    if !params[:format]
      params[:format]='xml'
    end
        
    redirect_to :controller => 'users', :action => 'show', :format => params[:format], :id => params[:id]
  end
  
  
end