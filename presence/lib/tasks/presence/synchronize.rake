namespace :presence do
  desc 'Synchronize Xmpp Server with Social Stream Rails Application'
  task :synchronize => [ 'presence:synchronize:connections', 'presence:synchronize:rosters' ]

  namespace :synchronize do

    desc "Synchronize user presence"
    task :connections, [:domain] => :environment do |t, args| 
      puts "Starting presence:synchronize:connections"
      unless args[:domain]
        puts "No web domain specified"
        domain = SocialStream::Presence.domain
        puts "Executing  rake presence:synchronize:connections[" + domain + "]"
      else
        domain = args[:domain]
      end
      SocialStream::Presence::XmppServerOrder::synchronizePresence(domain)
      puts "Synchronization complete"
    end

    desc "Synchronize Xmpp Server database with Social Stream Rails Application database"
    desc "Remove all rosters and populate rosters from Social Stream data."
    task :rosters, [:domain] => :environment do |t, args| 
        puts "Starting presence:synchronize:rosters"
        unless args[:domain]
          puts "No web domain specified"
          domain = SocialStream::Presence.domain
          puts "Executing  rake presence:synchronize:rosters[" + domain + "]"
        else
          domain = args[:domain]
        end
        SocialStream::Presence::XmppServerOrder::synchronizeRosters(domain)
        puts "Rosters Synchronization complete"
    end
    
    desc "Synchronize Xmpp Server database with Social Stream Rails Application database."
    desc "Remove all rooms and create one room (also knowledge as MUC) for each Social Stream group."
    task :rooms, [:domain] => :environment do |t, args| 
        puts "Starting presence:synchronize:rooms"
        unless args[:domain]
          puts "No web domain specified"
          domain = SocialStream::Presence.domain
          puts "Executing  rake presence:synchronize:rooms[" + domain + "]"
        else
          domain = args[:domain]
        end
        SocialStream::Presence::XmppServerOrder::synchronizeRooms(domain)
        puts "Rooms Synchronization complete"
    end
  end
end
