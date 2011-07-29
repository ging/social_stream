class CommonDocumentsController < InheritedResources::Base
  belongs_to_subjects :optional => true

  before_filter :subject!, :only => :index

  load_and_authorize_resource :except => :index

  def show
    path = resource.file.path(params[:style])

    respond_to do |format|
      format.all {
        send_file path, 
                  :filename => resource.file_file_name,
                  :type => resource.file_content_type,
                  :disposition => "inline"
      }
    end
  end
  
  def destroy
    @post_activity = resource.post_activity
    
    destroy!
  end

  private

  def subject
    @subject ||= association_chain[-1] || current_subject
  end

  def subject!
    @subject ||= association_chain[-1] || warden.authenticate!
  end

  def collection
    @activities = subject.wall(:profile,
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
