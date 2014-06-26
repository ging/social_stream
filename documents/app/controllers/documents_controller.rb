class DocumentsController < ApplicationController
  include SocialStream::Controllers::Objects

  before_filter :profile_subject!, :only => :index

  def index
    respond_to do |format|
      format.html {
        collection

        render collection if request.xhr?
      }

      format.json { render :json => collection.to_json(helper: self) }
    end
  end

  def show
    respond_to do |format|
      format.html {render :action => :show}
      format.json {render :json => resource.to_json(helper: self) }
      format.any {
        path = resource.file.path(params[:style] || params[:format])

        head(:not_found) and return unless File.exist?(path)

        send_file path,
                 :filename => resource.file_file_name,
                 :disposition => "inline",
                 :type => request.format
      }
    end
  end

  def original
    respond_to do |format|
      format.any {
        path = resource.file.path(params[:style])

        head(:not_found) and return unless File.exist?(path)

        send_file path,
                 :filename => resource.file_file_name,
                 :disposition => "inline",
                 :type => resource.format
      }
    end

  end

  def create
    super do |format|
      format.json { render :json => resource.to_json(helper: self), status: :created }
      format.js
      format.all {
        if resource.new_record?
          render action: :new
        else
          redirect = 
            ( request.referer.present? ?
              ( request.referer =~ /new$/ ?
                resource :
                request.referer ) :
              home_path )

          redirect_to redirect
        end
      }
    end
  end

  def update
    update! do |success, failure|
      failure.html { render :action => :show }
      success.html { render :action => :show }
    end
  end

  def destroy
    super do |format|
      format.html {
        redirect_to :home
      }

      format.js
    end
  end

  #TODO: we have to add the mimetype as in videos_controller
  def download
    path = @document.file.path(params[:style])

    head(:not_found) and return unless File.exist?(path)

    send_file_options = {
      :filename => @document.file_file_name,
      :type => @document.file_content_type
    }

    #Update download count
    resource.increment_download_count

    send_file(path, send_file_options)
  end

  private

  def allowed_params
    [ :file ]
  end

  class << self
    def index_object_type
      [ :Audio, :Video, :Picture, :Document ]
    end
  end
end
