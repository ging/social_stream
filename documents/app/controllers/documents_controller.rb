class DocumentsController < ApplicationController
  include SocialStream::Controllers::Objects

  before_filter :profile_subject!, :only => :index

  def index
    respond_to do |format|
      format.html {
        collection

        if params[:no_layout].present?
          render :layout => false
        end
      }

      format.json { render :json => collection }
    end
  end
  
  def create
    super do |format|
      format.json { render :json => resource }
      format.all {redirect_to request.referer || home_path}
    end
  end

  def update
    update! do |success, failure|
      failure.html { render :action => :show }
      success.html { render :action => :show }
    end
  end

  def show
    respond_to do |format|
      format.json {render :json => resource }
      format.html {render :action => :show}
      format.any {
        path = resource.file.path(params[:style] || params[:format])

        send_file path,
                 :filename => resource.file_file_name,
                 :disposition => "inline",
                 :type => request.format
      }
    end
  end

  #TODO: we have to add the mimetype as in videos_controller
  def download
    path = @document.file.path(params[:style])

    head(:bad_request) and return unless File.exist?(path)

    send_file_options = {
      :filename => @document.file_file_name,
      :type => @document.file_content_type
    }

    send_file(path, send_file_options)
  end

  private

  class << self
    def index_object_type
      [ :Audio, :Video, :Picture, :Document ]
    end
  end
end
