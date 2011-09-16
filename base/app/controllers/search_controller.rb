class SearchController < ApplicationController
  
  #before_filter :authenticate_user! #??
  
  def index
    if params[:mode].eql? "header_search"
      @search_result = header_search params[:search_query]
      render :partial => "header_search", :locals => {:search_result => @search_result}
      return
    else
      @search_result = global_search params[:search_query]      
    end
  end



  private
  def global_search query
    return search query, params[:page].present? ? params[:page] : 1, 10
  end
  
  def header_search query
    return search query, params[:page].present? ? params[:page] : 1, 3
  end
  
  def search query, page, per_page
    result = Hash.new
    SocialStream.subjects.each do |subject_sym|
      result.update({subject_sym => ThinkingSphinx.search("*#{query}*", :page => page, :per_page => per_page, :classes => [subject_sym.to_s.classify.constantize])})
      result.update({(subject_sym.to_s+"_total").to_sym => ThinkingSphinx.count("*#{query}*", :classes => [subject_sym.to_s.classify.constantize])})
    end
    return result
    
  end
end
