class RemoteusersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    if params[:slug].present?
      u = RemoteUser.find_or_create_using_wslug(params[:slug])
      
      t = Tie.create!(:sender => current_user.actor,
                      :receiver => u.actor,
                      :relation_name => "friend") 
      
      p = Post.create!(:text => "testing testing",
                       :_activity_tie_id => t)                                                                  
    end
    
    respond_to do |format|
      format.html
    end
  end
  
end