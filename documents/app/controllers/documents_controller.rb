class DocumentsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include SocialStream::Controllers::Objects

  belongs_to_subjects :optional => true

  before_filter :profile_subject!, :only => :index

  PER_PAGE=20
  
  def index
    super do |format|
      format.json { render :json => collection.map{|a| a.activity_objects.first.document.to_json} }
      if params[:no_layout].present?
        format.html { render :action => :index, :layout => false }      
      else  
        format.html { render :action => :index }
      end
    end
  end
  
  def create
    super do |format|
      format.json { render :json => resource }
      format.all {redirect_to request.referer || home_path}
    end
  end

  def update
    update! do |success, failure|
      failure.html { render :action => :show }
      success.html { render :action => :show }
    end
  end

  def show
    respond_to do |format|
      format.json {render :json => resource }
      format.html {render :action => :show}
      format.any {
        path = resource.file.path(params[:style] || params[:format])

        send_file path,
                 :filename => resource.file_file_name,
                 :disposition => "inline",
                 :type => request.format
      }
    end
  end

  #TODO: we have to add the mimetype as in videos_controller
  def download
    path = @document.file.path(params[:style])

    head(:bad_request) and return unless File.exist?(path)

    send_file_options = {
      :filename => @document.file_file_name,
      :type => @document.file_content_type
    }

    send_file(path, send_file_options)
  end

  private

  def collection
    @activities = profile_subject.wall(:profile,
                                       :for => current_subject,
                                       :object_type => Array(self.class.index_object_type))
    if params[:query].present? 
      @activities = @activities.joins(:activity_objects => :document).where('documents.title LIKE ?', get_search_query)
    end
    @activities = @activities.page(params[:page]).per(PER_PAGE)
  end

  class << self
    def index_object_type
      [ :Audio, :Video, :Picture, :Document ]
    end
  end
  
  def get_search_query
    search_query = ""
    param = strip_tags(params[:query]) || ""
    bare_query = param unless bare_query.html_safe?
    search_query_words = bare_query.strip.split
    search_query_words.each_index do |i|
      search_query+= search_query_words[i] + " " if i < (search_query_words.size - 1)
      search_query+= "%" + search_query_words[i] + "% " if i == (search_query_words.size - 1)
    end
    return search_query.strip
  end
end
