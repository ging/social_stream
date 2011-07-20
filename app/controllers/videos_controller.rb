class VideosController < CommonDocumentsController
  respond_to :html,:js
  
  def show
    path = @video.file.path(params[:style])
    if(params[:style].present?)
      path = path.split('.')[0]+'.'+params[:style]
    end
    respond_to do |format|
      format.all {send_file path, 
                  :type => @video.file_content_type,
                  :disposition => "inline"}
    end
  end
end
