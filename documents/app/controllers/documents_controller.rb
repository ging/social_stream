class DocumentsController < InheritedResources::Base
  respond_to :html, :js

  belongs_to_subjects :optional => true

  before_filter :profile_subject!, :only => :index

  load_and_authorize_resource :except => :index

  SEND_FILE_METHOD = :default
  def create
    super do |format|
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
      format.html {render :action => :show}
      format.all {
        path = resource.file.path(params[:style] || params[:format])

        send_file path,
        :filename => resource.file_file_name,
        :disposition => "inline"
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

    # Ask Victor about the rationale of this:
    case SEND_FILE_METHOD
    when :apache then send_file_options[:x_sendfile] = true
    when :nginx then head(:x_accel_redirect => path.gsub(Rails.root, ''))
    end

    send_file(path, send_file_options)
  end

  def destroy
    @post_activity = resource.post_activity

    destroy!
  end

  private

  def collection
    @activities = profile_subject.wall(:profile,
    :for => current_subject,
    :object_type => Array(self.class.index_object_type)).
    page(params[:page]).
    per(params[:per])
  end

  class << self
    def index_object_type
      [ :Audio, :Video, :Picture, :Document ]
    end
  end
end
