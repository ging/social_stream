class SearchController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  helper_method :get_search_query

  RESULTS_SEARCH_PER_PAGE=12
  MIN_QUERY=2
  def index
    @search_result =
      if params[:q].blank? || too_short_query
        []
      elsif params[:mode].eql? "header_search"
        search :quick
      elsif params[:type].present?
        focus_search
      else
        search :extended
      end

    respond_to do |format|
      format.html {
        if params[:mode] == "header_search"
          render :partial => "header_search"
        end
      }
      format.json {
        json_obj = (
          params[:type].present? ?
          { params[:type].pluralize => @search_result } :
          @search_result
        )

        render :json => json_obj
      }
    end
  end

  private

  def search mode
    models = ( mode.to_s.eql?("quick") ?
              SocialStream.extended_search_models :
              SocialStream.quick_search_models
             ).dup

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
    @search_class_sym = params[:type].singularize.to_sym unless params[:type].blank?
    search_class = @search_class_sym.to_s.classify.constantize
    result = ThinkingSphinx.search(get_search_query, :classes => [search_class])
    result = authorization_filter result
    return Kaminari.paginate_array(result).page(params[:page]).per(RESULTS_SEARCH_PER_PAGE)
  end

  def too_short_query
    bare_query = strip_tags(params[:q]) unless bare_query.html_safe?
    return bare_query.strip.size < MIN_QUERY
  end

  def get_search_query
    search_query = ""
    param = strip_tags(params[:q]) || ""
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
      if result.is_a? SocialStream::Models::Object
        filtered_results << result if can? :read, result
      else
      filtered_results << result
      end
    end
    return filtered_results
  end
end
