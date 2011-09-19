module SearchHelper  
  def subject_with_details subject
    subject = subject.subject if subject.is_a? Actor    
    render :partial => subject.class.to_s.pluralize.downcase + '/' + subject.class.to_s.downcase + '_with_details',
           :locals => {subject.class.to_s.downcase.to_sym => subject}
  end
  
  def focus_search_link text, search_class, query
    search_class = search_class.to_s if search_class.is_a? Class or search_class.is_a? Symbol
    link_to text, search_path(:focus => search_class.downcase.pluralize, :search_query => query )
  end
end