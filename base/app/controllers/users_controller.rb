class UsersController < ApplicationController
  include SocialStream::Controllers::Subjects

  load_and_authorize_resource except: :current

  before_filter :authenticate_user!, only: :current

  respond_to :html, :xml, :js
  
  def index
    raise ActiveRecord::RecordNotFound
  end

  def current
    respond_to do |format|
      format.json { render json: current_user.to_json }
    end
  end

  # Supported through devise
  def new; end; def create; end
  # Not supported yet
  def destroy; end

  protected

  # Overwrite resource method to support slug
  # See InheritedResources::BaseHelpers#resource
  def resource
    @user ||= end_of_association_chain.find_by_slug!(params[:id])
  end
end
