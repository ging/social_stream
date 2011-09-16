class SubjectsController < ApplicationController
  def lrdd
    actor = Actor.find_by_webfinger!(params[:id])

    redirect_to polymorphic_path(actor.subject, :format => :xrd)
  end
end
