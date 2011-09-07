class SearchController < ApplicationController
  
  #before_filter :authenticate_user! #??
  
  def index
    if params[:mode].eql? "header_search"
      @search = Actor.search "*#{params[:id]}*"
    else
      @search = ThinkingSphinx.search "*#{params[:id]}*"      
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => {:results => @search.to_json} }
    end
  end

end
