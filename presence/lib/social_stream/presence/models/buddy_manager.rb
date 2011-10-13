require 'xmpp4r'
require 'xmpp4r/muc'
require 'xmpp4r/roster'
require 'xmpp4r/client'
require 'xmpp4r/message'

module SocialStream
  module Presence
    module Models
      module BuddyManager
        extend ActiveSupport::Concern
        
        included do
          after_create :save_buddy
        end
        
        module InstanceMethods
          
          def save_buddy
            
            unless self.receiver.subject_type == "User" and self.sender.subject_type == "User"
              return
            end

            #XMPP DOMAIN
            domain = SocialStream::Presence.domain
            #PASSWORD
            password= SocialStream::Presence.password
            #SS Username
            ss_name = SocialStream::Presence.social_stream_presence_username
              
            user_sid = self.sender.slug + "@" + domain
            buddy_sid = self.receiver.slug + "@" + domain
            buddy_name =  self.receiver.name
              
            #Check Subscription_type
            if isBidirectionalTie
              sType = "both"
            else
              sType = "from"
            end 
            
            begin
              ss_sid = ss_name + "@" + domain
              client = Jabber::Client.new(Jabber::JID.new(ss_sid))
              client.connect
              client.auth(password)
   
              #Sending a message
              #AddItemToRoster[UserSID,BuddySID,BuddyName,Subscription_type]
              msg = Jabber::Message::new(ss_sid, "AddItemToRoster&" + user_sid + "&" + buddy_sid + "&" + buddy_name + "&" + sType)
              msg.type=:chat
              client.send(msg)
              client.close()

            rescue Exception => e
              case e
                when Errno::ECONNREFUSED
                  puts "Connection to XMPP Server refused"
                else
                  puts "Unknown exception: #{e.to_s}"
              end
            end   
            
          end
          
          def isBidirectionalTie
            return true
          end
          
        end
      end
    end
  end
end