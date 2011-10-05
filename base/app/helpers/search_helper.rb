module SearchHelper  
  def model_with_details model
    model = model.model if model.is_a? Actor    
    render :partial => model.class.to_s.pluralize.downcase + '/' + model.class.to_s.downcase + '_with_details',
           :locals => {model.class.to_s.downcase.to_sym => model}
  end
  
  def focus_search_link text, search_class, query
    search_class = search_class.to_s if search_class.is_a? Class or search_class.is_a? Symbol
    link_to text, search_path(:focus => search_class.downcase.pluralize, :search_query => query ), :remote => true
  end
  
  def too_short_query?
    return true if params[:search_query].blank?
    bare_query = strip_tags(params[:search_query]) unless bare_query.html_safe?
    return bare_query.strip.size < SearchController::MIN_QUERY
  end
end