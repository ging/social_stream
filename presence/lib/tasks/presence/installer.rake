namespace :presence do
  desc 'Copy ejabberd files to the xmpp server and write configuration files'
  task :install => [ 'presence:install:copy_xmpp_server_files', 'presence:install_xmpp_server' , 'presence:autoconfigure_xmpp_server' ]

  namespace :install do

    desc "Copy ejabberd files to the xmpp server"
    task :copy_xmpp_server_files => :environment do
      puts "Starting presence:install:copy_xmpp_server_files"
      
      presence_root = File.expand_path("../../../../", __FILE__)
      opath = presence_root + "/ejabberd";
      dpath = SocialStream::Presence.scripts_path + "/sstream_ejabberd_files";
      
      #Cleaning dpath
      SocialStream::Presence::XmppServerOrder::executeCommands(["rm -r " + dpath,"mkdir -p " + dpath])
      #Copy folders
      SocialStream::Presence::XmppServerOrder::copyFolder(opath,dpath)
      
      puts "Social Stream Ejabberd files copied to " + dpath + " in Xmpp Server"
      puts "Copy_xmpp_server_files: Task complete"
    end


    desc "Copy ejabberd files to the xmpp server and write configuration files" 
    task :xmpp_server, [:sudo_password] => :environment do |t, args| 
        puts "Starting presence:install_xmpp_server"
        
        user = SocialStream::Presence::XmppServerOrder::getExecutorUser 
        unless user
            puts "Specify ssh_user for remote access!"
            exit 0
        end
        
        #Get password
        if args[:sudo_password]
          password = args[:sudo_password]
        else
          puts "[sudo] password for " + user + ":\n"
          system "stty -echo"
          password = STDIN.gets.chomp
          system "stty echo"
          
          if password.gsub(" ","")==""
            puts "Please specify [sudo] password for " + user + " to execute the installer"
            puts "You can provided it from keyboard input or execute the task as presence:install:xmpp_server[sudo_password]"
            exit 0
          end        
        end
        
        #Copy files
        Rake::Task["presence:install:copy_xmpp_server_files"].execute
        
        commands = []
        
        #Give permissions to installation script
        commands << "chmod +x " + SocialStream::Presence.scripts_path + "/sstream_ejabberd_files/installer.sh"     

        #Get autoconfiguration values
        options = SocialStream::Presence::XmppServerOrder::autoconf([])

        #Execute installation script
        commands << "echo " + password + " | sudo -S " + SocialStream::Presence.scripts_path + "/sstream_ejabberd_files/installer.sh \"ejabberd_module_path=" + SocialStream::Presence.ejabberd_module_path + "\" \"scripts_path=" + SocialStream::Presence.scripts_path + "\" \"" + options + "\""
        
        #Execution order
        output = SocialStream::Presence::XmppServerOrder::executeCommands(commands)
        
        puts output
        puts "Installation complete"
    end
    
    
    desc "Autoconfigure options"
    task :autoconfigure_xmpp_server, [:options] => :environment do |t, args|
      puts "Starting presence:install:autoconfigure_xmpp_server"
      
      if args[:options]
        manual_options = args[:options].split(';') 
        manual_options.each do |option|
          if option.split('=').length != 2
            puts "Syntax error: presence:install:autoconfigure_xmpp_server[key1=value1;key2=value2;removeThiskey=remove]"
          end
        end
      else
        manual_options = []
      end
      
      commands = []
      options = SocialStream::Presence::XmppServerOrder::autoconf(manual_options)
      commands << SocialStream::Presence.scripts_path + "/sstream_ejabberd_files/installer.sh \"onlyconf=true\" \"" + options + "\"" 
      
      #Execution order
      output = SocialStream::Presence::XmppServerOrder::executeCommands(commands)
      
      puts output
      puts "Autoconfigure complete"
    end
    
  end
end
