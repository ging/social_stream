module SearchHelper  
  def too_short_query?
    return true if params[:q].blank?
    bare_query = strip_tags(params[:q]) unless bare_query.html_safe?
    return bare_query.strip.size < SearchController::MIN_QUERY
  end
  
  def render_global_search_for model
    render_model_view model, "_global_search"    
  end
  
  def render_focus_search_for model
    render_model_view model, "_focus_search"    
  end
  
  def model_with_details model
    render_model_view model, "_with_details"
  end
  
  def render_model_view model, type
    model = model.model if model.is_a? Actor    
    render :partial => model.class.to_s.pluralize.downcase + '/' + model.class.to_s.downcase + type,
           :locals => {model.class.to_s.downcase.to_sym => model}
    
  end
  
  def get_search_query_words
    search_query = ""
    bare_query = strip_tags(params[:q]) unless bare_query.html_safe?
    return bare_query.strip.split
  end

  def search_class(type, model_sym)
    case type
    when :selected
     params[:type].present? &&
      params[:type].eql?(model_sym.to_s) &&
      'selected' || ''
    when :disabled
      search_results?(model_sym) &&
        '' || 'disabled'
    else
      raise "Unknown select search class type"
   end
  end

  def search_results?(model_sym)
    ThinkingSphinx.count(get_search_query,
                         :classes => [model_sym.to_s.classify.constantize]) > 0
  end

  def search_tab(model_sym)
    span_options = {}
    span_options[:class] = "#{ search_class(:selected, model_sym) } #{ search_class(:disabled, model_sym) } #{ model_sym.to_s.pluralize.downcase }"

    results = search_results?(model_sym)

    unless results
      span_options[:title] = t('search.no_subject_found', :subject => model_sym.to_s)
    end

    link_to_if results,
               content_tag(:span, t("#{ model_sym }.title.other"), span_options),
               search_path(:type => model_sym,
                           :q => params[:q]),
               :remote => true
  end
end
