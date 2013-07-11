class ActorsController < ApplicationController
  respond_to :json

  def index
    @actors = Actor.
      name_search(params[:q]).
      subject_type(params[:type])

    if params[:stranger].present?
      @actors = @actors.not_contacted_from(current_subject)
    end

    @actors = @actors.page(params[:page])

    render json: @actors, helper: self
  end
end
