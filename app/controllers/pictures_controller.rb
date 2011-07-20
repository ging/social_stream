class PicturesController < InheritedResources::Base
  load_and_authorize_resource
  
  respond_to :html,:js
  
  def show
    path = @picture.file.path(params[:style])
    respond_to do |format|
      format.all {send_file path, 
                  :type => @picture.file_content_type,
                  :disposition => "inline"}
    end
  end
  
  def index
    @document_activities = current_subject.wall(:profile,
                                        :for => current_subject,
                                        :object_type => :Picture).page(params[:page]).per(params[:per])
  end
  
  def destroy
    @post_activity = resource.post_activity
    
    destroy!
  end
end  