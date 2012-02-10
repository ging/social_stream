module XmppHelper
  
  def getChatContacts 
     connected_users = []
     all_users = []
     
     #Get bidirectional contacts
     contacts = current_user.contact_actors(:type=>:user)
     
     #Apply filters
     
     contacts.each do |contact|
       if contact.user.connected
         connected_users << contact.user
       end
       all_users << contact.user 
     end

    return [connected_users,all_users]  
  end
  
end
