# Changes context for users to represent other subjects
class RepresentationsController < ApplicationController
  def create
    self.current_subject = Representation.new(params[:representation]).subject

    redirect_to(request.referer || home_path)
  end
end
