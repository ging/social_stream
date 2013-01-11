class PermissionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :relation!

  def index
    @permissions = @relation.permissions

    respond_to do |format|
      format.html {
        render partial: 'index', layout: false
      }
    end
  end

  private

  def relation!
    @relation = current_subject.relations.find(params[:relation_id])
  end
end
