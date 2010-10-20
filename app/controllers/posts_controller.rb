class PostsController < InheritedResources::Base
  respond_to :html, :xml, :js

  def destroy
    @post_activity = resource.post_activity

    destroy!
  end
end
