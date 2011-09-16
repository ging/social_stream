class DocumentsController < CommonDocumentsController
  respond_to :html,:js,:png,:jpeg,:bmp,:gif
  
  SEND_FILE_METHOD = :default

  def create
    super do |format|
      format.all {redirect_to request.referer || home_path}
    end
  end
  
  #TODO: we have to add the mimetype as in videos_controller
  def download
    path = @document.file.path(params[:style])
    head(:bad_request) and return unless File.exist?(path) 
    send_file_options = {:filename=>@document.file_file_name, :type => @document.file_content_type} 

    case SEND_FILE_METHOD
      when :apache then send_file_options[:x_sendfile] = true
      when :nginx then head(:x_accel_redirect => path.gsub(Rails.root, ''))
    end

    send_file(path, send_file_options)
  end

  class << self
    def index_object_type
      [:Audio,:Video,:Picture,:Document]
    end
  end
end
