class SearchController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  helper_method :get_search_query

  RESULTS_SEARCH_PER_PAGE=12
  MIN_QUERY=2
  def index
    if params[:search_query].blank? or too_short_query
    @search_result = []
    else
      if params[:mode].eql? "header_search"
        @search_result = search :quick
        render :partial => "header_search"
      return
      else
        if params[:focus].present?
          @search_result = focus_search
        else
          @search_result = search :extended
        end
      end
    end
  end

  private

  def search mode
    models = SocialStream.extended_search_models
    models = SocialStream.quick_search_models if mode.to_s.eql? "quick"
    models.map! {|model_sym| model_sym.to_s.classify.constantize}
    result = ThinkingSphinx.search(get_search_query, :classes => models)
    result = authorization_filter result
    if mode.to_s.eql? "quick"
      result = Kaminari.paginate_array(result).page(1).per(7)
    else
      result = Kaminari.paginate_array(result).page(params[:page]).per(RESULTS_SEARCH_PER_PAGE)
    end
    return result
  end

  def focus_search
    @search_class_sym = params[:focus].singularize.to_sym unless params[:focus].blank?
    search_class = @search_class_sym.to_s.classify.constantize
    result = ThinkingSphinx.search(get_search_query, :classes => [search_class])
    result = authorization_filter result
    return Kaminari.paginate_array(result).page(params[:page]).per(RESULTS_SEARCH_PER_PAGE)
  end

  def too_short_query
    bare_query = strip_tags(params[:search_query]) unless bare_query.html_safe?
    return bare_query.strip.size < MIN_QUERY
  end

  def get_search_query
    search_query = ""
    param = strip_tags(params[:search_query]) || ""
    bare_query = param unless bare_query.html_safe?
    search_query_words = bare_query.strip.split
    search_query_words.each_index do |i|
      search_query+= search_query_words[i] + " " if i < (search_query_words.size - 1)
      search_query+= "*" + search_query_words[i] + "* " if i == (search_query_words.size - 1)
    end
    return search_query.strip
  end

  def authorization_filter results
    filtered_results = Array.new
    results.each do |result|
      puts result
      if result.is_a? SocialStream::Models::Object
        filtered_results << result if can? :read, result
      else
      filtered_results << result
      end
    end
    return filtered_results
  end
end
