class TagsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @tags = ActsAsTaggableOn::Tag.where('name like ?','%'+params[:tag]+'%').limit(10)
    response = @tags.map{ |t| { 'key' => t.name, 'value' => t.name } }.to_json
    if @tags.count == 0
      response = "[{\"key\":\""+params[:tag]+"\" , \"value\":\""+params[:tag]+"\"}]"
    end

    respond_to do |format|
      format.json { render :text => response}
    end
  end
end