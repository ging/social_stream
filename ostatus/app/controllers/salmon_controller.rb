class SalmonController < ApplicationController
  def index
    SocialStream::ActivityStreams.from_salmon_callback request.body.read
  end
end
