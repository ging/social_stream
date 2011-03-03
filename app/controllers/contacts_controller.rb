class ContactsController < ApplicationController
  
  def index
    
    
    return if current_subject.blank?
    
    myContacts = Array.new
    mySubjects = current_subject.subjects(:direction => :receivers)
    
    return if mySubjects.blank?
    
    #Fill the array with actor name/actorId of all the actors which has a tie with current_subject
    mySubjects.each do |aSubject|
      aSubjectD = {}
      aSubjectD['key'] = aSubject.name
      aSubjectD['value'] = aSubject.actor_id.to_s
      myContacts << aSubjectD
    end
    
    respond_to do |format|
      format.html #index.html.erb
      format.json { render :text => myContacts.to_json }
    end
    
  end

end
