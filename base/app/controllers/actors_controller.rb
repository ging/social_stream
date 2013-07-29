class ActorsController < ApplicationController
  respond_to :json

  def index
    @actors = Actor.
      name_search(params[:q]).
      subject_type(params[:type])

    if params[:stranger].present?
      @actors = @actors.not_contacted_from(sender)
    end

    @actors = @actors.page(params[:page])

    render json: @actors, helper: self
  end

  private

  def sender
    @sender ||=
      params[:sender_id] && Actor.find(params[:sender_id]) ||
        current_subject
  end
end
