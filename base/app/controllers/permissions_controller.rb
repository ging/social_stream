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
    @relation = Relation.find(params[:relation_id])

    authorize! :read, @relation
  end
end
