class RemoteSubjectsController < ApplicationController
  def index
    raise ActiveRecord::RecordNotFound if params[:q].blank?

    @remote_subject =
      RemoteSubject.find_or_create_by_webfinger_uri!(params[:q])
      
    redirect_to @remote_subject
  end

  def show
    @remote_subject =
      RemoteSubject.find_by_slug!(params[:id])

    if params[:refresh]
      @remote_subject.refresh_webfinger!
    end
  end
end
