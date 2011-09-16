class CommentsController < InheritedResources::Base
  load_and_authorize_resource

  respond_to :html, :xml, :js

  def destroy
    @post_activity = resource.post_activity

    destroy!
  end
  
  def show    
    parent = resource.post_activity.parent
    redirect_to polymorphic_path(parent.direct_object,:anchor => dom_id(parent))
  end


end
