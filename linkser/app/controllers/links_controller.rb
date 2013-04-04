class LinksController < ApplicationController
  include SocialStream::Controllers::Objects

  def create
    super do |format|
      format.json { render :json => resource }
      format.js { render }
      format.all {redirect_to link_path(resource) || home_path}
    end
  end

  private

  def allowed_params
    [ :url, :image, :callback, :width, :height ]
  end
end
