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
            ss_sid = ss_name + "@" + domain
              
            user_sid = self.sender.slug + "@" + domain
            user_name =  self.sender.name  
            buddy_sid = self.receiver.slug + "@" + domain
            buddy_name =  self.receiver.name
            
            
            begin
              client = Jabber::Client.new(Jabber::JID.new(ss_sid))
              client.connect
              client.auth(password)
   
              #Check if is a positive and replied tie         
              if self.bidirectional?
                #SetRosterForBidirectionalTie[UserASID,UserBSID,UserAName,UserBName]
                msg = Jabber::Message::new(ss_sid, "SetRosterForBidirectionalTie&" + user_sid + "&" + buddy_sid + "&" + buddy_name + "&" + user_name) 
              elsif self.positive?
                #Case: Possitive tie unidirectional
                sType = "from"
                #AddItemToRoster[UserSID,BuddySID,BuddyName,Subscription_type]
                msg = Jabber::Message::new(ss_sid, "AddItemToRoster&" + user_sid + "&" + buddy_sid + "&" + buddy_name + "&" + sType)
              else
                return  
              end

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
          
        end
      end
    end
  end
end