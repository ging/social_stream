class Site::ClientsController < ApplicationController
  include SocialStream::Controllers::Subjects
  include SocialStream::Controllers::Authorship

  before_filter :authenticate_user!

  load_and_authorize_resource except: :index

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
    destroy! { :home }
  end

  def collection
    get_collection_ivar ||
      set_collection_ivar(build_collection)
  end
    
  protected

  def build_collection
    current_subject.managed_site_clients
  end

  def permitted_params
    params.permit resource_request_name => resource_permitted_params,
                  resource_instance_name => resource_permitted_params
  end

  def resource_permitted_params
    [
      :name,
      :description,
      :url,
      :callback_url
    ]
  end
end
