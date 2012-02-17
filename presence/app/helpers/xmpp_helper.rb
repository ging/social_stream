module XmppHelper
  
  def getChatContacts 
    #Get bidirectional contacts
    contacts = current_user.contact_actors(:type=>:user)
     
    #Apply filters
    #...
     
    return contacts;
  end
 
end
