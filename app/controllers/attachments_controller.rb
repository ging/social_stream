class AttachmentsController < InheritedResources::Base
  load_and_authorize_resource
  
  respond_to :html,:js
  
  SEND_FILE_METHOD = :default

  def show
    show! do |format|
      format.all { download }
      format.html
    end
  end
  
  def download
    path = @attachment.file.path(params[:style])
    head(:bad_request) and return unless File.exist?(path) 
    send_file_options = {} 

    case SEND_FILE_METHOD
      when :apache then send_file_options[:x_sendfile] = true
      when :nginx then head(:x_accel_redirect => path.gsub(Rails.root, ''))
    end

    send_file(path, send_file_options)
  end

end