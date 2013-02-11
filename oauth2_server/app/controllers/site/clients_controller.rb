class Site::ClientsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :set_author_ids, only: [ :create, :update ]

  def index
    @developer_clients = current_subject.developer_site_clients
  end

  def show
    @client = Site::Client.find params[:id]
  end

  def new
    @client = Site::Client.new
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

  private

  def set_author_ids
    params[:site_client][:author_id]      = current_subject.actor_id
    params[:site_client][:user_author_id] = current_user.actor_id
    params[:site_client][:owner_id]       = current_subject.actor_id
  end
end
