class SalmonController < ApplicationController
  def index
    actor = Actor.find_by_slug! params[:slug]

    SocialStream::ActivityStreams.from_salmon_callback request.body.read, actor
  end
end
