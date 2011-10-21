class VideosController < CommonDocumentsController
  respond_to :html,:js
  


  def show
    path = @video.file.path(params[:style])
    if(params[:style].present?) && Document::STYLE_FORMAT[params[:style]]
      path = path.split('.')[0]+'.'+Document::STYLE_FORMAT[params[:style]]
    end
    respond_to do |format|
      format.html {render :action => :show}
      format.all {send_file path, 
                  :type => Document::STYLE_MIMETYPE[params[:style]],  # CANT USE: @video.file_content_type because it is allways video/mp4 and breaks explorer and firefox
                  :disposition => "inline"}
    end
  end

end
