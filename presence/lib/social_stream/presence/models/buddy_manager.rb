module SocialStream
  module Presence
    module Models
      module BuddyManager
        extend ActiveSupport::Concern
        
        included do
          after_create :save_buddy
          after_destroy :remove_buddy
        end
        
        def save_buddy
          
          unless SocialStream::Presence.enable
            return
          end
          
          unless self.receiver and self.sender
            return
          end
          
          unless self.receiver.subject_type == "User" and self.sender.subject_type == "User"
            return
          end

          begin
            #WEB DOMAIN
            domain = SocialStream::Presence.domain
            user_sid = self.sender.slug + "@" + domain
            user_name =  self.sender.name  
            buddy_sid = self.receiver.slug + "@" + domain
            buddy_name =  self.receiver.name
            site_name = I18n.t('site.name').delete(' ')
            
            #Check if is a positive and replied tie         
            if self.bidirectional?
              #Execute setRosterForBidirectionalTie(userASid,userBSid,userANick,userBNick,groupForA,groupForB)
              SocialStream::Presence::XmppServerOrder::setRosterForBidirectionalTie(user_sid,buddy_sid,user_name,buddy_name,site_name,site_name)
            elsif self.positive?
              #Case: Possitive tie unidirectional
              #Execute addBuddyToRoster(userSID,buddySID,buddyNick,buddyGroup,subscription_type)
              subscription_type = "from"
              SocialStream::Presence::XmppServerOrder::addBuddyToRoster(user_sid,buddy_sid,buddy_name,site_name,subscription_type)
            else
              #Negative Tie
              
              if self.contact.positive_replied?
                #Bidirectional contacts
                #Execute unsetRosterForBidirectionalTie(user_sid,oldfriend_sid,oldfriendNick,oldfriendGroup)
                SocialStream::Presence::XmppServerOrder::unsetRosterForBidirectionalTie(buddy_sid,user_sid,user_name,site_name)
              else
                SocialStream::Presence::XmppServerOrder::removeBuddyFromRoster(user_sid,buddy_sid)
              end
              
              return  
            end
          
          rescue Exception => e
            logger.warn ("WARNING Exeception in Buddy Manager save_buddy: " + e.message)
            puts ("WARNING Exeception in Buddy Manager save_buddy: " + e.message)
          end
          
        end
        
        
        def remove_buddy 
#            
#            unless SocialStream::Presence.enable
#              return
#            end
#            
#            unless self.receiver and self.sender
#              return
#            end
#            
#            unless self.receiver.subject_type == "User" and self.sender.subject_type == "User"
#              return
#            end
#            
#            if self.contact.established?
#              return
#            end
# 
#            #XMPP DOMAIN
#            domain = SocialStream::Presence.domain
#            user_sid = self.sender.slug + "@" + domain
#            user_name =  self.sender.name  
#            buddy_sid = self.receiver.slug + "@" + domain
#            
#            #Check if is a positive and replied tie         
#            if self.bidirectional?
#              #Execute unsetRosterForBidirectionalTie(user_sid,oldfriend_sid,oldfriendNick,oldfriendGroup)
#              SocialStream::Presence::XmppServerOrder::unsetRosterForBidirectionalTie(buddy_sid,user_sid,user_name,site_name)
#            elsif self.positive?
#              #Case: Possitive tie unidirectional
#              #Execute removeBuddyFromRoster(user_sid,buddy_sid)
#              SocialStream::Presence::XmppServerOrder::removeBuddyFromRoster(user_sid,buddy_sid)
#            else
#              return  
#            end
#            
        end
      end
    end
  end
end
