class PostsController < InheritedResources::Base
  respond_to :html, :xml, :js

  load_and_authorize_resource

  def destroy
    @post_activity = resource.post_activity

    destroy!
  end
end
