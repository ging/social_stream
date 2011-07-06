class AudiosController < InheritedResources::Base
  load_and_authorize_resource
  
  def show
    path = @audio.file.path(params[:style])
    respond_to do |format|
      format.all {send_file path, 
                  :type => @audio.file_content_type,
                  :disposition => "inline"}
    end
  end
  
  def index
    @document_activities = current_subject.wall(:profile,
                                        :for => current_subject,
                                        :object_type => :Audio).page(params[:page]).per(params[:per])
  end
  
end