namespace :presence do
  desc 'Synchronize the Xmpp Server database with the Social Stream database'
  task :synchronize => [ 'presence:synchronize:connections', 'presence:synchronize:rosters' ]

  namespace :synchronize do

    desc "Synchronize user presence."
    task :connections => :environment do
      puts "Starting presence:synchronize:connections"
      puts "Synchronization complete"
    end

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
