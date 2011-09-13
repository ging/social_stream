class SearchController < ApplicationController
  
  #before_filter :authenticate_user! #??
  
  def index
    if params[:mode].eql? "header_search"
      @search_result = ThinkingSphinx.search "*#{params[:id]}*", :page => 1, :per_page => 10, :classes => [User, Group]
      render :partial => "header_search", :locals => {:search_result => @search_result}
      return
    else
      @search_result = ThinkingSphinx.search "*#{params[:id]}*"      
    end
  end

end
