require "social_stream/presence/config"
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
            domain = Socialstream::Presence::DOMAIN
            #PASSWORD
            password= Socialstream::Presence::PASSWORD
            
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
              client = Jabber::Client.new(Jabber::JID.new('social_stream-presence@trapo'))
              client.connect
              password = Socialstream::Presence::PASSWORD
              client.auth(password)
   
              #Sending a message
              #AddItemToRoster[UserSID,BuddySID,BuddyName,Subscription_type]
              msg = Jabber::Message::new('social_stream-presence@trapo', "AddItemToRoster&" + user_sid + "&" + buddy_sid + "&" + buddy_name + "&" + sType)
              msg.type=:chat
              client.send(msg) 
            rescue Errno::ECONNREFUSED
              #Rescue...
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