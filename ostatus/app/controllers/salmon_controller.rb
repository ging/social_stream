class SalmonController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    actor = Actor.find_by_slug! params[:slug]

    SocialStream::ActivityStreams.from_salmon_callback request.body.read, actor
  end
end
