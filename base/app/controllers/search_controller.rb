class SearchController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  #before_filter :authenticate_user! #??

  FOCUS_SEARCH_PER_PAGE=16
  MIN_QUERY=2
  def index
    @search_class_sym = params[:focus].singularize.to_sym unless params[:focus].blank?
    if params[:search_query].blank? or too_short_query
      @search_result = nil_search
    else
      if params[:mode].eql? "header_search"
        @search_result = header_search
        render :partial => "header_search", :locals => {:search_result => @search_result}
      return
      else
        if params[:focus].present?
          @search_result = focus_search
        else
          @search_result = global_search
        end
      end
    end
  end

  private

  def too_short_query
    bare_query = strip_tags(params[:search_query]) unless bare_query.html_safe?
    return bare_query.strip.size < MIN_QUERY
  end

  def get_search_query
    search_query = ""
    bare_query = strip_tags(params[:search_query]) unless bare_query.html_safe?
    search_query_words = bare_query.strip.split
    search_query_words.each_index do |i|
      search_query+= search_query_words[i] + " " if i < (search_query_words.size - 1)
      search_query+= "*" + search_query_words[i] + "* " if i == (search_query_words.size - 1)
    end
    return search_query.strip
  end

  def global_search
    return search 6
  end

  def header_search
    return search 3
  end

  def search max_results
    result = Hash.new
    total_shown = 0
    SocialStream.subjects.each do |subject_sym|
      result.update({subject_sym => ThinkingSphinx.search(get_search_query, :classes => [subject_sym.to_s.classify.constantize]).page(1).per(max_results)})
      result.update({(subject_sym.to_s+"_total").to_sym => ThinkingSphinx.count(get_search_query, :classes => [subject_sym.to_s.classify.constantize])})
    end
    return result
  end

  def focus_search
    string_class = params[:focus].singularize
    search_class = string_class.classify.constantize
    return ThinkingSphinx.search(get_search_query, :classes => [search_class]).page(params[:page]).per(FOCUS_SEARCH_PER_PAGE)
  end

  def nil_search
    if params[:focus].present?
      result = []
    else
      result = Hash.new
      SocialStream.subjects.each do |subject_sym|
        result.update({subject_sym => []})
        result.update({(subject_sym.to_s+"_total").to_sym => 0})
      end
    end
    return result
  end
end
