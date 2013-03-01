class TagsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @tags =
      case params[:mode]
      when "popular"
        most_popular
      else
        match_tag
      end

    if @tags.blank? && params[:q].present?
      @tags = [ ActsAsTaggableOn::Tag.new(name: params[:q]) ]
    end

    respond_to do |format|
      format.json {
        render json: @tags
      }
    end
  end

  private

  def match_tag
    ActsAsTaggableOn::Tag.where('name LIKE ?',"%#{ params[:q] }%").page(params[:page])
  end

  def most_popular
    ActivityObject.tag_counts(:order => "count desc").page(params[:page])
  end
end
