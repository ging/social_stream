class SearchController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  #before_filter :authenticate_user! #??

  FOCUS_SEARCH_PER_PAGE = 10
  def index
    if params[:search_query].blank?
      @search_result = nil_search
      @search_class_sym = params[:focus].singularize.to_sym unless params[:focus].blank?
    else
      search_query = get_search_query params[:search_query]
      if params[:mode].eql? "header_search"
        @search_result = header_search search_query
        render :partial => "header_search", :locals => {:search_result => @search_result}
      return
      else
        if params[:focus].present?
          @search_result = focus_search params[:focus], search_query, params[:page].present? ? params[:page].to_i : 1
          @search_class_sym = params[:focus].singularize.to_sym
        else
          @search_result = global_search search_query
        end
      end
    end
  end

  private

  def get_search_query bare_query
    search_query = ""
    bare_query = strip_tags(bare_query) unless bare_query.html_safe?
    search_query_words = bare_query.strip.split
    search_query_words.each_index do |i|
      search_query+= search_query_words[i] + " " if i < (search_query_words.size - 1)
      search_query+= "*" + search_query_words[i] + "* " if i == (search_query_words.size - 1)
    end
    return search_query.strip 
  end

  def global_search query
    return search query, 10
  end

  def header_search query
    return search query, 3
  end

  def search query, max_results
    result = Hash.new
    total = 0
    total_shown = 0
    SocialStream.subjects.each do |subject_sym|
      result.update({subject_sym => ThinkingSphinx.search(query, :page => 1, :per_page => max_results, :classes => [subject_sym.to_s.classify.constantize])})
      result.update({(subject_sym.to_s+"_total").to_sym => ThinkingSphinx.count(query, :classes => [subject_sym.to_s.classify.constantize])})
      total+=ThinkingSphinx.count(query, :classes => [subject_sym.to_s.classify.constantize])
    end
    result.update({:total => total})
    result.update({:total_shown => total_shown})
    return result
  end

  def focus_search string_class, query, page
    string_class = string_class.singularize
    search_class = string_class.classify.constantize
    result = Hash.new
    result.update({string_class.to_sym => ThinkingSphinx.search(query, :page => page, :per_page => FOCUS_SEARCH_PER_PAGE, :classes => [search_class])})
    result.update({(string_class+"_total").to_sym => ThinkingSphinx.count(query, :classes => [search_class])})
    return result
  end

  def nil_search
    result = Hash.new
    SocialStream.subjects.each do |subject_sym|
      result.update({subject_sym => []})
      result.update({(subject_sym.to_s+"_total").to_sym => 0})
    end
    result.update({:total => 0})
    return result
  end
end
