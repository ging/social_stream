class LikesController < ApplicationController
  # Ensure the suitable tie exists
  before_filter :tie!, :only => :create

  # POST /activities/1/like.js
  def create
    @like = activity!.children.new :verb => "like"
		
    respond_to do |format|
      if @like.save
        tie!.activities << @like
        format.js
      else
        format.js
      end
    end
  end

  def destroy
    if (@like = activity!.liked_by(current_user).first)
      @like.destroy
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def activity
    @activity ||= Activity.find(params[:activity_id])
  end

  def activity!
    activity || raise(ActiveRecord::RecordNotFound)
  end

  def tie
    @tie ||= current_user.sent_ties(:receiver => activity!.receiver,
                                    :relation => activity!.relation).first
  end

  def tie!
    tie || raise(ActiveRecord::RecordNotFound)
  end
end
