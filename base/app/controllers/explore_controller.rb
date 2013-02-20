class ExploreController < ApplicationController
  def index
    respond_to do |format|
      format.html { 
        if request.xhr?
          render partial: params[:section].present? && params[:section].gsub(/[^a-z]/i, '') || "explore"
        end
      }
    end
  end
end
