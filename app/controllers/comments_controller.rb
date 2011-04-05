class CommentsController < InheritedResources::Base
  load_and_authorize_resource

  respond_to :html, :xml, :js

  def destroy
    @post_activity = resource.post_activity

    destroy!
  end

end
