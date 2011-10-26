namespace :presence do
  desc 'Synchronize Xmpp Server with Social Stream Rails Application'
  task :synchronize => [ 'presence:synchronize:connections', 'presence:synchronize:rosters' ]

  namespace :synchronize do

    desc "Synchronize user presence"
    task :connections => :environment do
      puts "Starting presence:synchronize:connections"
      SocialStream::Presence::XmppServerOrder::synchronize_presence
      puts "Synchronization complete"
    end

    desc "Synchronize Xmpp Server database with Social Stream Rails Application database"
    desc "Remove all rosters and populate rosters from Social Stream data."
    task :rosters => :environment do
        puts "Starting presence:synchronize:rosters"
        SocialStream::Presence::XmppServerOrder::synchronize_rosters
        puts "Rosters Synchronization complete"
    end
  end
end
