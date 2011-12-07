require 'xmpp4r'
require 'xmpp4r/muc'
require 'xmpp4r/roster'
require 'xmpp4r/client'
require 'xmpp4r/message'
require 'net/ssh'
require 'net/sftp'

module SocialStream
  module Presence
    class XmppServerOrder
      
      class << self
               
          def setRosterForBidirectionalTie(userASid,userBSid,userANick,userBNick,groupForA,groupForB)
              executeEmanagementCommand("setBidireccionalBuddys",[userASid,userBSid,userANick,userBNick,groupForA,groupForB])
          end 
          
          
          def unsetRosterForBidirectionalTie(userSid,oldfriendSid,oldfriendNick,oldfriendGroup)
              executeEmanagementCommand("unsetBidireccionalBuddys",[userSid,oldfriendSid,oldfriendNick,oldfriendGroup])
          end
          
          
          def addBuddyToRoster(userSid,buddySid,buddyNick,buddyGroup,subscription_type)
              executeEmanagementCommand("addBuddyToRoster",[userSid,buddySid,buddyNick,buddyGroup,subscription_type])
          end
          
          
          def removeBuddyFromRoster(userSid,buddySid)
              executeEmanagementCommand("removeBuddyFromRoster",[userSid,buddySid])
          end   
          
          

          def synchronizePresence
            if isEjabberdNodeUp
              output = executeEmanagementCommand("getConnectedUsers",[])
              user_slugs = output.split("\n")
              synchronizePresenceForSlugs(user_slugs)
            else
              resetPresence
              return "Xmpp Server Down: Reset Connected Users"
            end  
          end
          
          
          def removeAllRosters
              executeEmanagementCommand("removeAllRosters",[])
          end
          
          
          def synchronizeRosters
            commands = []
            
            #"Remove all rosters"
            commands << buildCommand("emanagement","removeAllRosters",[])

            #"Populate rosters"
            users = User.all
            checkedUsers = []
          
            users.each do |user|
              checkedUsers << user.slug
              contacts = user.contact_actors(:type=>:user)
              contacts.each do |contact|
                unless checkedUsers.include?(contact.slug)
                  domain = SocialStream::Presence.domain
                  user_sid = user.slug + "@" + domain
                  contact_sid = contact.slug + "@" + domain
                  commands << buildCommand("emanagement","setBidireccionalBuddys",[user_sid,contact_sid,user.name,contact.name,"SocialStream","SocialStream"])
                end
              end
            end
            
            executeCommands(commands)
          end
          
     
          def synchronizePresenceForSlugs(user_slugs)
            
            #Check connected users
            users = User.find_all_by_connected(true)
            
            users.each do |user|
              if user_slugs.include?(user.slug) == false
                user.connected = false
                user.save!
              end
            end
            
            user_slugs.each do |user_slug|
              u = User.find_by_slug(user_slug)
              if (u != nil && u.connected  == false)
                u.connected = true
                u.save!
              end
            end
          end
          
          
          def resetPresence
            users = User.find_all_by_connected(true)
    
            users.each do |user|
              user.connected = false
              user.save!
            end
          end
          
          
          #Installation methods
          
          def copyFolder(oPath,dPath)
            if SocialStream::Presence.remote_xmpp_server
              #Remote mode
              copyRemoteFolder(oPath,dPath)
            else
              #Local mode
              SocialStream::Presence::XmppServerOrder::executeCommand("cp -r " + oPath + "/* " + dPath)
            end
          end
          
          
          def copyRemoteFolder(localPath,remotePath)
            begin
              if SocialStream::Presence.ssh_password             
               
                Net::SFTP.start(SocialStream::Presence.ssh_domain, SocialStream::Presence.ssh_user, :password => SocialStream::Presence.ssh_password, :auth_methods => ["password"] ) do |sftp|
                  recursiveCopyFolder(localPath,remotePath,sftp)
                end 
                
              else
                #SSH with authentication key instead of password              
                Net::SFTP.start(SocialStream::Presence.ssh_domain, SocialStream::Presence.ssh_user) do |sftp|
                  recursiveCopyFolder(localPath,remotePath,sftp)
                end 
              end
              output="Ok"
            rescue Exception => e
              case e
                when Net::SSH::AuthenticationFailed
                  output = "AuthenticationFailed on remote access"
                else
                  output = "Unknown exception in copyRemoteFolder method: #{e.to_s}"
              end
            end  
 
            return output
          end
          
          
          def recursiveCopyFolder(localPath,remotePath,sftp) 
            # Create directory if not exits
            sftp.mkdir(remotePath)
            # Upload files to the remote host        
            Dir.foreach(localPath) do |f|
              file_path = localPath + "/#{f}"
              if File.file?(file_path)
                sftp.upload(file_path, remotePath + "/#{f}")
              elsif File.directory?(file_path) and f!="." and f!=".."
                recursiveCopyFolder(file_path,remotePath + "/#{f}",sftp)
              end
            end
          end

          def autoconf(options)
            autoconf=[]
            
            #Add autoconfiguration options
            #autoconf.push("key=value")

            autoconf.push("scripts_path=" + SocialStream::Presence.scripts_path)
            autoconf.push("ejabberd_password=" + SocialStream::Presence.xmpp_server_password)
            autoconf.push("server_domain=" + SocialStream::Presence.domain)
            autoconf.push("cookie_name=" + Rails.application.config.session_options[:key])
            
            #Param options
            if options
              options.each do |option|
                autoconf = addManualOption(autoconf,option)
              end
            end
            
            #return "[key1=value1,key2=value2,key3=value3]"
            return "[" + autoconf.join(',') + "]"
          end
          
          
          def addManualOption(array,option)
            
            optionSplit = option.split("=")
            unless optionSplit.length == 2
              return array
            end
            
            key = optionSplit[0];
            array.each do |element|
              if element.split("=")[0]==key
                #Replace element
                array[array.index(element)]=option
                return array
              end
            end
            #Add option
            array.push(option)
            return array
          end
          
          
          def getExecutorUser
            if SocialStream::Presence.remote_xmpp_server
              if SocialStream::Presence.ssh_user
                return SocialStream::Presence.ssh_user
              else
                return nil
              end
            else
              return %x["whoami"].gsub(/\n/,"");
            end
          end
          
          
          #Execution commands manage  
        
          def buildCommand(script,order,params)
            command = SocialStream::Presence.scripts_path + "/" + script + " " + order
            params.each do |param|
              command = command + " " + param.split(" ")[0]
            end
            return command
          end
          
          def executeEmanagementCommand(order,params)
            command = buildCommand("emanagement",order,params)
            executeCommand(command)
          end
          
          def executeCommand(command)
            output = executeCommands([command])
            return output
          end
          
          def executeCommands(commands)
            if commands.length > 1
              puts "Executing the following commands:"
              commands.each do |command|
                puts parsingCommand(command)
              end  
              puts "Command list finish"
            elsif commands.length == 1
              puts "Executing " + parsingCommand(commands[0])
            else
              puts "No command to execute"
              return
            end
                       
            if SocialStream::Presence.remote_xmpp_server
              output = executeRemoteCommands(commands)
            else
              #SocialStream::Presence.remote_xmpp_server=false
              output = executeLocalCommands(commands)
            end
            return output
          end
        
          def executeLocalCommands(commands)
            output="No command received";
            commands.each do |command|
                output = %x[#{command}];
            end
            return output
          end
        
          def executeRemoteCommands(commands)
            output="No command received";
            
            begin
              if SocialStream::Presence.ssh_password
                Net::SSH.start( SocialStream::Presence.ssh_domain, SocialStream::Presence.ssh_user, :password => SocialStream::Presence.ssh_password, :auth_methods => ["password"]) do |session|
                  commands.each do |command|
                    output = session.exec!(command)
                  end
                end
              else
                #SSH with authentication key instead of password
                Net::SSH.start( SocialStream::Presence.ssh_domain, SocialStream::Presence.ssh_user) do |session|
                  commands.each do |command|
                    output = session.exec!(command)
                  end
                end
              end
            rescue Exception => e
              case e
                when Net::SSH::AuthenticationFailed
                  output = "AuthenticationFailed on remote access"
                else
                  output = "Unknown exception in executeRemoteCommands method: #{e.to_s}"
              end
            end  
 
            return output
          end

        
        
         #Help methods
         
          def isEjabberdNodeUp
              output = executeEmanagementCommand("isEjabberdNodeStarted",[])
              nodeUp = output.split("\n")[0]
              return (nodeUp and nodeUp.strip()=="true")
          end
        
          def parsingCommand(command)
              #Hide passwords on sudo commands: command pattern = "echo password | sudo -S order"
              return command.gsub(/echo ([aA-zZ]+) [|] sudo -S [.]*/,"echo ****** | sudo -S \\2")
          end
        
         #Xmpp client manage methods
          
          def getSocialStreamUserSid
            #XMPP DOMAIN
            domain = SocialStream::Presence.domain
            #SS Username
            ss_name = SocialStream::Presence.social_stream_presence_username
            return ss_name + "@" + domain
          end
          
          
          def openXmppClientForSocialStreamUser
            begin            
              password= SocialStream::Presence.password
              client = Jabber::Client.new(Jabber::JID.new(getSocialStreamUserSid))
              client.connect
              client.auth(password)
              return client
            rescue Exception => e
              case e
                when Errno::ECONNREFUSED
                  puts "Connection to XMPP Server refused"
                  return nil
                else
                  puts "Unknown exception: #{e.to_s}"
                  return nil
              end  
            end
          end
          
          
          def sendXmppChatMessage(client,dest_sid,body)
                msg = Jabber::Message::new(dest_sid, body)
                msg.type=:chat
                client.send(msg)
          end
               
      end
    end
  end
end