class CommentsController < ApplicationController
  include SocialStream::Controllers::Objects

  def show    
    parent = resource.post_activity.parent
    redirect_to polymorphic_path(parent.direct_object,:anchor => dom_id(parent))
  end

  private

  def allowed_params
    [:text]
  end
end
