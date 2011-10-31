require 'xmpp4r'
require 'xmpp4r/muc'
require 'xmpp4r/roster'
require 'xmpp4r/client'
require 'xmpp4r/message'

module SocialStream
  module Presence
    class XmppServerOrder
      
      class << self
        
        
          def setRosterForBidirectionalTie(userASid,userBSid,userANick,userBNick,groupForA,groupForB)
            if SocialStream::Presence.remote_xmpp_server
              puts "Not implemented setRosterForBidirectionalTie(userASid,userBSid,userANick,userBNick,groupForA,groupForB) for remote_xmpp_server"
              return
            else
              #SocialStream::Presence.remote_xmpp_server=false
              executeEmanagementLocalCommand("setBidireccionalBuddys",[userASid,userBSid,userANick,userBNick,groupForA,groupForB])
            end
          end 
          
          
          def unsetRosterForBidirectionalTie(userSid,oldfriendSid,oldfriendNick,oldfriendGroup)
            if SocialStream::Presence.remote_xmpp_server
              puts "Not implemented unsetRosterForBidirectionalTie(user_sid,oldfriend_sid,oldfriendNick,oldfriendGroup) for remote_xmpp_server"
              return
            else
              #SocialStream::Presence.remote_xmpp_server=false
              executeEmanagementLocalCommand("unsetBidireccionalBuddys",[userSid,oldfriendSid,oldfriendNick,oldfriendGroup])
            end
          end
          
          
          def addBuddyToRoster(userSid,buddySid,buddyNick,buddyGroup,subscription_type)
            if SocialStream::Presence.remote_xmpp_server
              puts "Not implemented addBuddyToRoster(userSID,buddySID,buddyNick,buddyGroup,subscription_type) for remote_xmpp_server"
              return
            else
              #SocialStream::Presence.remote_xmpp_server=false
              executeEmanagementLocalCommand("addBuddyToRoster",[userSid,buddySid,buddyNick,buddyGroup,subscription_type])
            end
          end
          
          
          def removeBuddyFromRoster(userSid,buddySid)
            if SocialStream::Presence.remote_xmpp_server
              puts "Not implemented removeBuddyFromRoster(userSid,buddySid) for remote_xmpp_server"
              return
            else
              #SocialStream::Presence.remote_xmpp_server=false
              executeEmanagementLocalCommand("removeBuddyFromRoster",[userSid,buddySid])
            end
          end
          
          
          #Before delete contact (destroy ties) callback
          def removeBuddy(contact)
            
            unless SocialStream::Presence.enable
              return
            end
            
            unless contact.receiver.subject_type == "User" and contact.sender.subject_type == "User"
              return
            end
 
            #XMPP DOMAIN
            domain = SocialStream::Presence.domain
            user_sid = contact.sender.slug + "@" + domain
            user_name =  contact.sender.name  
            buddy_sid = contact.receiver.slug + "@" + domain
            buddy_name =  contact.receiver.name
            
            #Check for bidirecctional
            
            if contact.sender.contact_actors(:type=>:user).include?(contact.receiver)
              #Bidirectional contacts
              #Execute unsetRosterForBidirectionalTie(user_sid,oldfriend_sid,oldfriendNick,oldfriendGroup)
              SocialStream::Presence::XmppServerOrder::unsetRosterForBidirectionalTie(buddy_sid,user_sid,user_name,"SocialStream")
            elsif contact.sender.contact_actors(:type=>:user, :direction=>:sent).include?(contact.receiver)
              #Unidirectional contacts
              SocialStream::Presence::XmppServerOrder::removeBuddyFromRoster(user_sid,buddy_sid)
            end
            
          end
          
          
          def synchronize_presence
            if SocialStream::Presence.remote_xmpp_server  
              
              begin
                client = openXmppClientForSocialStreamUser
                if client
                  sendXmppChatMessage(client,getSocialStreamUserSid,"Synchronize")
                  client.close()
                  return "Ok"
                else
                  reset_presence
                  return "Reset Connected Users"
                end
              rescue
                puts "Error in SocialStream::Presence::XmppServerOrder::synchronize_presence"
              end
              
            else
              #SocialStream::Presence.remote_xmpp_server=false
              
              #Get connected users locally 
              output = executeEmanagementLocalCommand("isEjabberdNodeStarted",[])
              nodeUp = output.split("\n")[3]
              
              if nodeUp and nodeUp.strip() == "true"
                users = []
                output = %x[ejabberdctl connected-users]
                sessions = output.split("\n")
  
                sessions.each do |session|
                  users << session.split("@")[0]
                  puts session.split("@")[0]
                end
                
                synchronize_presence_for_slugs(users)  
                
              else
                reset_presence
                return "Xmpp Server Down: Reset Connected Users"
              end
              
            end
          end
          
          
          def remove_all_rosters
            if SocialStream::Presence.remote_xmpp_server
              puts "Not implemented SocialStream::Presence::XmppServerOrder::remove_all_rosters for remote_xmpp_server"
              return
            else
            #SocialStream::Presence.remote_xmpp_server=false
              executeEmanagementLocalCommand("removeAllRosters",[])
            end
          end
          
          
          def synchronize_rosters
            puts "Removing all rosters"
            remove_all_rosters
            puts "Rosters removed"
       
            puts "Populate rosters"
            users = User.all
            checkedUsers = []
          
            users.each do |user|
              checkedUsers << user.slug
              contacts = user.contact_actors(:type=>:user)
              contacts.each do |contact|
                unless checkedUsers.include?(contact.slug)
                  domain = SocialStream::Presence.domain
                  user_sid = user.slug + "@" + domain
                  contact_sid = contact.slug + "@" + domain  
                  setRosterForBidirectionalTie(user_sid,contact_sid,user.name,contact.name,"SocialStream","SocialStream")
                end
              end
            end
          end
          
          
          
          #Help methods
          
          def getSocialStreamUserSid
            #XMPP DOMAIN
            domain = SocialStream::Presence.domain
            #SS Username
            ss_name = SocialStream::Presence.social_stream_presence_username
            return ss_name + "@" + domain
          end
          
          
          def openXmppClientForSocialStreamUser
            begin            
              password= SocialStream::Presence.password
              client = Jabber::Client.new(Jabber::JID.new(getSocialStreamUserSid))
              client.connect
              client.auth(password)
              return client
            rescue Exception => e
              case e
                when Errno::ECONNREFUSED
                  puts "Connection to XMPP Server refused"
                  return nil
                else
                  puts "Unknown exception: #{e.to_s}"
                  return nil
              end  
            end
          end
          
          
          def sendXmppChatMessage(client,dest_sid,body)
                msg = Jabber::Message::new(dest_sid, body)
                msg.type=:chat
                client.send(msg)
          end
          
          
          def synchronize_presence_for_slugs(user_slugs)
            #Check connected users
            users = User.find_all_by_connected(true)
            
            users.each do |user|
              if user_slugs.include?(user.slug) == false
                user.connected = false
                user.save!
              end
            end
            
            user_slugs.each do |user_slug|
              u = User.find_by_slug(user_slug)
              if (u != nil && u.connected  == false)
                u.connected = true
                u.save!
              end
            end
          end
          
          
          def reset_presence
            users = User.find_all_by_connected(true)
    
            users.each do |user|
              user.connected = false
              user.save!
            end
          end
          
          
          def executeEmanagementLocalCommand(order,params)
            command = SocialStream::Presence.scripts_path + "/emanagement " + order
            params.each do |param|
              command = command + " " + param.split(" ")[0]
            end
            puts "Executing " + command
            output = %x[#{command}];
            return output
          end
        
        
      end
    end
  end
end