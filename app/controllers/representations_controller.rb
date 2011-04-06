# Changes context for users to represent other subjects
class RepresentationsController < ApplicationController
  before_filter :load_representation

  authorize_resource

  def create
    self.current_subject = @representation.subject

    redirect_to(request.referer || home_path)
  end

  private

  # Build representation from params
  def load_representation
    @representation = Representation.new(params[:representation])
  end
end
