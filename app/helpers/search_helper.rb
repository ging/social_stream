module SearchHelper  
  def subject_search_result subject
    render :partial => subject.class.to_s.pluralize.downcase + '/' + subject.class.to_s.downcase + '_search_result',
           :locals => {subject.class.to_s.downcase.to_sym => subject}
  end
end