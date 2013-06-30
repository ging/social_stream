class Site::ClientsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :set_author_ids, only: [ :new, :create, :update ]

  load_and_authorize_resource

  def index
    @clients = current_subject.managed_site_clients
  end

  def create
    @client = Site::Client.new params[:site_client]

    if @client.save
      respond_to do |format|
        format.html { redirect_to @client }
      end
    else
      respond_to do |format|
        format.html { render :new }
      end
    end
  end

  def edit
    @client = Site::Client.find params[:id]
  end

  def update
    @client = Site::Client.find params[:id]

    if @client.update_attributes params[:client]
      respond_to do |format|
        format.html { redirect_to @client }
      end
    else
      respond_to do |format|
        format.html { render :edit }
      end
    end
  end

  def destroy
    @client.destroy

    redirect_to home_path
  end

  private

  def set_author_ids
    params[:site_client] ||= HashWithIndifferentAccess.new
    params[:site_client][:author_id]      = current_subject.actor_id
    params[:site_client][:user_author_id] = current_user.actor_id
    params[:site_client][:owner_id]       = current_subject.actor_id
  end
end
