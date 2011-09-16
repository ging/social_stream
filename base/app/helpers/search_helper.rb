module SearchHelper  
  def subject_with_details subject
    subject = subject.subject if subject.is_a? Actor    
    render :partial => subject.class.to_s.pluralize.downcase + '/' + subject.class.to_s.downcase + '_with_details',
           :locals => {subject.class.to_s.downcase.to_sym => subject}
  end
end