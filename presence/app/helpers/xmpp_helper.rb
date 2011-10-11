module XmppHelper
  def getChatContacts 
     connected_users = []   
     contacts = getBidirectionalContacts
     contacts.each do |contact|
       if current_user.name != contact.receiver.name && contact.receiver.subject_type == "User" && contact.receiver.user.connected
         connected_users << contact.receiver
       end
     end
     
    return connected_users  
  end
  
  def getBidirectionalContacts
    #Code for new SS Version
#    return current_user.contact_actors(:direction => :both)
    
    contacts = []
    csenders = current_user.sent_contacts
    creceivers = current_user.received_contacts
    
    csenders.each do |csender|
      creceivers.each do |creceiver|
        if ((csender.sender.name == creceiver.receiver.name) && (csender.receiver.name == creceiver.sender.name))
            contacts << csender
          break
        end
      end
    end
    return contacts
  end

end
