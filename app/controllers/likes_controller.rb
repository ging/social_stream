class LikesController < ApplicationController
  # POST /activities/1/like.js
  def create
    @like = Like.new(current_subject, params[:activity_id])

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
    @like = Like.find!(current_subject, params[:activity_id])

    respond_to do |format|
      if @like.destroy
        format.js
      else
        format.js
      end
    end
  end
end
