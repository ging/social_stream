class LikesController < ApplicationController
  before_filter :authenticate_user!, :indirect_object

  # POST /activities/1/like.js
  def create
    @like = Like.build(current_subject, @indirect_id)
    
    respond_to do |format|
      if @like.save
        format.js
      else
        format.js
      end
    end
  end

  # DELETE /activities/1/like.js
  def destroy
    @like = Like.find!(current_subject, @indirect_id)
    
    respond_to do |format|
      if @like.destroy
        format.js
      else
        format.js
      end
    end
  end
  
  private
  
  def indirect_object
    if params[:activity_id].present?
     @indirect_id = Activity.find(params[:activity_id])
    elsif params[:user_id].present?
     @indirect_id = User.find_by_slug!(params[:user_id])
    elsif params[:group_id].present?
     @indirect_id = Group.find_by_slug!(params[:group_id])
    end
  end
end
