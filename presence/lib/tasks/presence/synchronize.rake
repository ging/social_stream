namespace :presence do
  desc 'Synchronize Xmpp Server with Social Stream Rails Application'
  task :synchronize => [ 'presence:synchronize:connections', 'presence:synchronize:rosters' ]

  namespace :synchronize do

    desc "Synchronize user presence."
    task :connections => :environment do
      puts "Starting presence:synchronize:connections"
      
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
            desc "Reset connected users when XMMP Server Down"
            puts "Connection to XMPP Server refused: Reset Connected Users"
            users = User.find_all_by_connected(true)
            users.each do |user|
              user.connected = false
              user.save!
            end
          else
            puts "Unknown exception: #{e.to_s}"
            return
        end  
      end              
    
    puts "Synchronization complete"
    end

    desc "Synchronize Xmpp Server database with Social Stream Rails Application database"
    desc "Remove all rosters and populate rosters from Social Stream data."
    task :rosters => :environment do
        puts "Starting presence:synchronize:rosters"
        
        #XMPP DOMAIN
        domain = SocialStream::Presence.domain
        #PASSWORD
        password= SocialStream::Presence.password
        #SS Username
        ss_name = SocialStream::Presence.social_stream_presence_username      
        ss_sid = ss_name + "@" + domain 
        
        puts "Connecting to Xmpp Server"
        client = Jabber::Client.new(Jabber::JID.new(ss_sid))
        client.connect
        puts "Authentication..."
        client.auth(password)
        puts "Connected to Xmpp Server"
        
        puts "Remove all rosters"
        msg = Jabber::Message::new(ss_sid, "SynchronizeRosters")
        msg.type=:chat
        client.send(msg)
        
   
        puts "Populate rosters"
        users = User.all
        checkedUsers = []
      
        users.each do |user|
          checkedUsers << user.slug
          contacts = user.contact_actors(:type=>:user)
          contacts.each do |contact|
            unless checkedUsers.include?(contact.slug)
              user_sid = user.slug + "@" + domain
              buddy_sid = contact.slug + "@" + domain  
              msg = Jabber::Message::new(ss_sid, "SetRosterForBidirectionalTie&" + user_sid + "&" + buddy_sid + "&" + user.name + "&" + contact.name)
              msg.type=:chat
              client.send(msg)
            end
          end
        end

        puts "Synchronization complete"
        puts "Closing connection"
        client.close()  
        puts "Connection closing"
      
    end
  end
end
