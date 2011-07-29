class VideosController < CommonDocumentsController
  respond_to :html,:js
  

  
  def show
    path = @video.file.path(params[:style])
    if(params[:style].present?) && Document::STYLE_FORMAT[params[:style]]
      path = path.split('.')[0]+'.'+Document::STYLE_FORMAT[params[:style]]
    end
    respond_to do |format|
      format.all {send_file path, 
                  :type => params[:style]=="thumb" ? "image/png" : @video.file_content_type,
                  :disposition => "inline"}
    end
  end
end
