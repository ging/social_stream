module SearchHelper  
  
  def focus_search_link text, search_class, query
    search_class = search_class.to_s if search_class.is_a? Class or search_class.is_a? Symbol
    link_to text, search_path(:focus => search_class.downcase.pluralize, :search_query => query ), :remote => true
  end
  
  def too_short_query?
    return true if params[:search_query].blank?
    bare_query = strip_tags(params[:search_query]) unless bare_query.html_safe?
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
    bare_query = strip_tags(params[:search_query]) unless bare_query.html_safe?
    return bare_query.strip.split
  end
end