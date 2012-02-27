namespace :presence do
  desc 'Add web domains to Xmpp Server'
  task :multidomain => [ 'presence:multidomain:add', 'presence:multidomain:remove' ,
  'presence:multidomain:update']

  namespace :multidomain do

    desc "Add new web domain to XMPP Server"
    task :add, [:domain, :url] => :environment do |t, args| 
      puts "Starting presence:multidomain:add"
      unless args[:domain]
        puts "Please specify a web domain"
        puts "Syntax: rake presence:multidomain:add[domain,[url]]"
        return
      end
      response = SocialStream::Presence::XmppServerOrder::addWebDomain(args[:domain],args[:url])
      puts response
    end

    desc "Remove web domain from the XMPP Server"
    task :remove, [:domain] => :environment do |t, args| 
      puts "Starting presence:multidomain:remove"
      unless args[:domain]
        puts "Please specify a web domain"
        puts "Syntax: rake presence:multidomain:remove[domain]"
        return
      end
      response = SocialStream::Presence::XmppServerOrder::removeWebDomain(args[:domain])
      puts response
    end
    
    desc "Update web domain of XMPP Server"
    task :update, [:domain, :url] => :environment do |t, args| 
      puts "Starting presence:multidomain:update"
      unless args[:domain]
        puts "Please specify a web domain"
        puts "Syntax: rake presence:multidomain:update[domain,[url]]"
        return
      end
      response = SocialStream::Presence::XmppServerOrder::updateWebDomain(args[:domain],args[:url])
      puts response
    end

  end
end
