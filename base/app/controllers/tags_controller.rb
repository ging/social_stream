class TagsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    params[:limit] ||= 10

    @tags =
      case params[:mode]
      when "popular"
        most_popular
      else
        match_tag
      end

    if @tags.blank? && params[:tag].present?
      @tags = [ params[:tag] ]
    end

    respond_to do |format|
      format.json {
        response = @tags.map{ |t| { 'key' => t.name, 'value' => t.name } }.to_json

        render :text => response
      }
    end
  end

  private

  def match_tag
    ActsAsTaggableOn::Tag.where('name like ?',"%#{ params[:tag] }%").limit(params[:limit])
  end

  def most_popular
    ActivityObject.tag_counts(:limit => params[:limit], :order => "count desc")
  end
end
