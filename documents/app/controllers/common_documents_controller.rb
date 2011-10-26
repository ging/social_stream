class CommonDocumentsController < InheritedResources::Base
  respond_to :html, :js

  belongs_to_subjects :optional => true

  before_filter :profile_subject!, :only => :index

  load_and_authorize_resource :except => :index


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
      controller_name.classify
    end
  end
end
