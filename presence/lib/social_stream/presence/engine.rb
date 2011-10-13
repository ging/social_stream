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
          #Reset connected users when XMMP Server Down
          Thread.start {
            begin
              #XMPP DOMAIN
              domain = SocialStream::Presence.domain
              #PASSWORD
              password= SocialStream::Presence.password
              #SS Username
              ss_name = SocialStream::Presence.social_stream_presence_username
              
              ss_sid = ss_name + "@" + domain
              client = Jabber::Client.new(Jabber::JID.new(ss_sid))
              client.connect
              client.auth(password)
       
              msg = Jabber::Message::new(ss_sid, "Synchronize")
              msg.type=:chat
              client.send(msg)
              client.close()
            
            rescue Exception => e
              case e
                when Errno::ECONNREFUSED
                  begin
                    users = User.find_all_by_connected(true)
                    users.each do |user|
                      user.connected = false
                      user.save!
                    end
                    puts "Connection to XMPP Server refused: Reset Connected Users"
                  rescue
                  end
                else
                  puts "Unknown exception: #{e.to_s}"
              end  
            end           
          }
      end
      
    end
  end
end
