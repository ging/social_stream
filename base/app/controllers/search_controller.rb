class SearchController < ApplicationController
  
  #before_filter :authenticate_user! #??
  
  def index
    if params[:mode].eql? "header_search"
      @search_result = ThinkingSphinx.search "*#{params[:search_query]}*", :page => 1, :per_page => 10, :classes => SocialStream.subjects.map{|sym| sym = sym.to_s.classify.constantize}
      render :partial => "header_search", :locals => {:search_result => @search_result}
      return
    else
      @search_result = global_search params[:search_query]      
    end
  end



  private
  def global_search query
    result = Hash.new
    SocialStream.subjects.each do |subject_sym|
      result.update({subject_sym => ThinkingSphinx.search("*#{query}*", :page => 1, :per_page => 10, :classes => [subject_sym.to_s.classify.constantize])})
      result.update({(subject_sym.to_s+"_total").to_sym => ThinkingSphinx.count("*#{query}*", :classes => [subject_sym.to_s.classify.constantize])})
    end
    return result
  end
end
