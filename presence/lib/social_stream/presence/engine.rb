require 'xmpp4r'
require 'xmpp4r/muc'
require 'xmpp4r/roster'
require 'xmpp4r/client'
require 'xmpp4r/message'

module SocialStream
  module Presence
    class Engine < Rails::Engine
      config.to_prepare do
        
        #Patching Tie
        Tie.class_eval do
          include SocialStream::Presence::Models::BuddyManager
        end
        
      end 
               
      initializer "social_stream-presence.synchronize" do
          #Synchronize User Presence
          #Implement case XMMP Server Down
          Thread.start {
            begin
              client = Jabber::Client.new(Jabber::JID.new('social_stream-presence@trapo'))
              client.connect
              password = Socialstream::Presence::PASSWORD
              client.auth(password)
       
              msg = Jabber::Message::new("social_stream-presence@trapo", "Synchronize")
              msg.type=:chat
              client.send(msg)
              client.close()
            
            rescue Errno::ECONNREFUSED
              #XMPP Server Down
              #Reset Connected Users
              users = User.find_all_by_connected(true)
              users.each do |user|
                user.connected = false
                user.save!
              end
              
            end
          }
      end
      
    end
  end
end
