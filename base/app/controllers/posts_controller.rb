class PostsController < ApplicationController
  include SocialStream::Controllers::Objects

  private

  def allowed_params
    [:text]
  end
end
