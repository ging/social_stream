class DocumentsController < InheritedResources::Base
  load_and_authorize_resource
  
  respond_to :html,:js,:png,:jpeg,:bmp,:gif
  
  SEND_FILE_METHOD = :default
  
  def show
    path = @document.file.path(params[:style])
    respond_to do |format|
      format.all {send_file path, 
                  :type => @document.file_content_type,
                  :disposition => "inline"}
    end
  end
  
  def download
    path = @document.file.path(params[:style])
    head(:bad_request) and return unless File.exist?(path) 
    send_file_options = {} 

    case SEND_FILE_METHOD
      when :apache then send_file_options[:x_sendfile] = true
      when :nginx then head(:x_accel_redirect => path.gsub(Rails.root, ''))
    end

    send_file(path, send_file_options)
  end
  
  def index
    @subject = User.find_by_slug(params[:user_id]) || Group.find_by_slug(params[:group_id])
    
    @document_activities = (@subject ? @subject : current_subject).wall(:home,
                                        :for => current_subject,
                                        :object_type => [:Audio,:Video,:Picture,:Document]).page(params[:page]).per(params[:per])
  end
    
  def create
    super do |format|
      format.all {redirect_to request.referer || home_path}
    end
  end
  
  def destroy
    @post_activity = resource.post_activity

    destroy!
  end

end