class Site::ClientsController < ApplicationController
  include SocialStream::Controllers::Subjects
  include SocialStream::Controllers::Authorship

  before_filter :authenticate_user!

  load_and_authorize_resource

  def create
    create! do |success, error|
      success.html { 
        redirect_to polymorphic_path(resource, action: :edit, step: 2)
      }
      error.html { render :new }
    end
  end

  # Refresh the site client token
  def update_secret
    resource.refresh_secret!

    respond_to do |format|
      format.json { render json: { secret: resource.secret } }
    end
  end

  def destroy
    destroy! do
      redirect_to home_path
    end
  end

  protected

  def collection
    current_subject.managed_site_clients
  end
end
