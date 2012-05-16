require 'net/ssh'
require 'net/sftp'


module SocialStream
  module Presence
    class XmppServerOrder
      
      class << self
          
          ##################
          #Emanagement Calls
          ##################
    
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
          
          
          def createPersistentRoom(roomName,domain)
              executeEmanagementCommand("createPersistentRoom",[roomName,domain])
          end
          
          
          def destroyRoom(roomName,domain)
              executeEmanagementCommand("destroyRoom",[roomName,domain])
          end
         
         
         
         
          ##################
          # Presence synchronization
          ##################
          
          def synchronizePresence(webDomain)
            if isEjabberdNodeUp
              if (webDomain=="all")
                output = executeEmanagementCommand("getConnectedJids",[])
              else
                output = executeEmanagementCommand("getConnectedJidsByDomain",[webDomain])
              end
              user_jids = output.split("\n")
              synchronizePresenceForJids(user_jids)
            else
              resetPresence
              return "Xmpp Server Down: Reset Connected Users"
            end  
          end
          
          def synchronizePresenceForJids(user_jids)
            domains = getDomainsFromJids(user_jids)
            domains.each do |domain|
              user_slugs = getSlugsFromJids(user_jids,domain)
              synchronizePresenceForSlugs(user_slugs,domain) 
            end 
          end

          def getSlugsFromJids(user_jids,domain)
            user_slugs = []
            user_jids.each do |user_jid|
                if(user_jid.split("@")[1]==domain)
                  user_slugs << user_jid.split("@")[0] 
                end
             end
             return user_slugs
          end
          
          def getDomainsFromJids(user_jids)
            domains = []
            user_jids.each do |user_jid|
                domain=user_jid.split("@")[1]
                if !domains.include?(domain) 
                  domains << domain
                end
             end
             return domains
          end
                  
          def synchronizePresenceForSlugs(user_slugs,domain)
            
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
          
          
          #Reset presence for all domains
          def resetPresence
            users = User.find_all_by_connected(true)
    
            users.each do |user|
              user.connected = false
              user.save!
            end
          end
          
          
          
          
          ##################
          #  Rosters synchronization
          ################## 
         
          def removeAllRosters(webDomain)
              executeEmanagementCommand("removeAllRostersByDomain",[webDomain])
          end
          
          
          def synchronizeRosters(webDomain)
            commands = []
            
            #"Remove all rosters"
            commands << buildCommand("emanagement","removeAllRostersByDomain",[webDomain])

            #"Populate rosters"
            users = User.all
            checkedUsers = []
            site_name = I18n.t('site.name').delete(' ')
          
            users.each do |user|
              checkedUsers << user.slug
              contacts = user.contact_actors(:type=>:user)
              contacts.each do |contact|
                unless checkedUsers.include?(contact.slug)
                  user_sid = user.slug + "@" + webDomain
                  contact_sid = contact.slug + "@" + webDomain
                  commands << buildCommand("emanagement","setBidireccionalBuddys",[user_sid,contact_sid,user.name,contact.name,site_name,site_name])
                end
              end
            end
            
            executeCommands(commands)
          end
          
          
          
                    
          ##################
          #  Room (MUC) synchronization
          ################## 
          
          def removeAllRooms(webDomain)
              executeEmanagementCommand("destroyAllRoomsByDomain",[webDomain])
          end
          
          
          def synchronizeRooms(webDomain)
            commands = []
            
            #Remove all mucs
            commands << buildCommand("emanagement","destroyAllRoomsByDomain",[webDomain])

            #Populate mucs
            groups = Group.all

            groups.each do |group|
              commands << buildCommand("emanagement","createPersistentRoom",[group.slug,webDomain])
            end
            
            executeCommands(commands)
          end
         
         
         
         
          ##################
          #  Installation methods
          ##################
          
          def copyFolderToXmppServer(oPath,dPath)
            if SocialStream::Presence.remote_xmpp_server
              #Remote mode
              copyFolderToXmppServerRemote(oPath,dPath)
            else
              #Local mode
              executeCommand("cp -r " + oPath + "/* " + dPath)
            end
          end
          
          
          def copyFolderToXmppServerRemote(localPath,remotePath)
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
            
            #Check if localPath is a file
            if File.file?(localPath) and File.file?(remotePath)
              puts "Copy files..."
              sftp.upload(localPath, remotePath)
              return
            end
            
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
            autoconf.push("secure_rest_api=" + SocialStream::Presence.secure_rest_api.to_s)
            autoconf.push("cookie_name=" + Rails.application.config.session_options[:key])
            autoconf.push("web_domains=[" + SocialStream::Presence.domain + "]")
            autoconf.push("force_ssl=" + Rails.application.config.force_ssl.to_s()) 
            
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
          
          def generateRSAKeys(keysPath)
            
            unless File.directory?(keysPath)
              return "Keys path not exists"
            end
            
            #Require libraries
            require 'openssl'

            web_public_key_path=keysPath+"/web_rsa_key_public.pem"
            web_private_key_path=keysPath+"/web_rsa_key_private.pem"
            xmpp_public_key_path=keysPath+"/xmpp_rsa_key_public.pem"
            xmpp_private_key_path=keysPath+"/xmpp_rsa_key_private.pem"
            
            # .generate creates an object containing both keys
            web_rsa_key = OpenSSL::PKey::RSA.generate( 1024 )
            xmpp_rsa_key = OpenSSL::PKey::RSA.generate( 1024 )
            
            #Write keys as PEM's

            #Public Key
            web_rsa_key_public = web_rsa_key.public_key
            xmpp_rsa_key_public = xmpp_rsa_key.public_key
            output_public = File.new(web_public_key_path, "w")
            output_public.puts web_rsa_key_public
            output_public.close
            output_public = File.new(xmpp_public_key_path, "w")
            output_public.puts xmpp_rsa_key_public
            output_public.close
            puts "New Web Server public key stored in #{web_public_key_path}\n"
            #puts "New Web Server public key:\n#{web_rsa_key_public}\n"
            puts "New Xmpp Server public key stored in #{xmpp_public_key_path}\n"
            #puts "New Xmpp Server public key:\n#{xmpp_rsa_key_public}\n"
                       
            #Private Key
            web_rsa_key_private = web_rsa_key.to_pem
            xmpp_rsa_key_private = xmpp_rsa_key.to_pem
            output_private = File.new(web_private_key_path, "w")
            output_private.puts web_rsa_key_private
            output_private.close
            output_private = File.new(xmpp_private_key_path, "w")
            output_private.puts xmpp_rsa_key_private
            output_private.close
            puts "New Web Server private key stored in #{web_private_key_path}\n"
            #puts "New Web Server private key:\n#{web_rsa_key_private}\n"
            puts "New Xmpp Server private key stored in #{xmpp_private_key_path}\n"
            #puts "New Xmpp Server private key:\n#{xmpp_rsa_key_private}\n"
            
            puts "Finish"
          end
          
          
          
          
          ##################
          #  Execution commands management
          ##################
        
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
        
          def executeLocalCommand(command)
            puts "Executing " + parsingCommand(command)
            return executeLocalCommands([command])
          end
        
          def executeLocalCommands(commands)
            if commands.empty?
              return "No command received";
            end
            output=""
            commands.each do |command|
                response = %x[#{command}]
                output = output + response + "\n";
            end
            return output
          end
        
          def executeRemoteCommands(commands)
            if commands.empty?
              return "No command received";
            end
            
            begin
              output="";
              if SocialStream::Presence.ssh_password
                Net::SSH.start( SocialStream::Presence.ssh_domain, SocialStream::Presence.ssh_user, :password => SocialStream::Presence.ssh_password, :auth_methods => ["password"]) do |session|
                  commands.each do |command|
                    response = session.exec!(command)
                    if response != nil
                      output = output + response + "\n";
                    end
                  end
                end
              else
                #SSH with authentication key instead of password
                Net::SSH.start( SocialStream::Presence.ssh_domain, SocialStream::Presence.ssh_user) do |session|
                  commands.each do |command|
                    response = session.exec!(command)
                    if response != nil
                      output = output + "\n" + response
                    end
                  end
                end
              end
            rescue Exception => e
              case e
                when Net::SSH::AuthenticationFailed
                  return "ERROR: AuthenticationFailed on remote access"
                else
                  return "ERROR: Unknown exception in executeRemoteCommands method: #{e.to_s}"
              end
            end  
 
            return output
          end

        
        
        
          ##################
          #  Authorization methods
          ##################
          
          def authorization(params)
            case SocialStream::Presence.secure_rest_api
            when true
              #Authorization using asymmetric RSA keys
              begin
                #Require libraries
                require 'openssl'
                
                presence_root = File.expand_path("../../../../", __FILE__)
                xmpp_public_key_path = presence_root + "/rsa_keys/xmpp_rsa_key_public.pem";
                xmpp_public_key = OpenSSL::PKey::RSA.new(File.read(xmpp_public_key_path))
                
                stamp = xmpp_public_key.public_decrypt( params[:password] )
               
                #stamp = password#####timestamp#####hash
                stampParams=stamp.split("#####")
                password = stampParams[0]
                timestamp = stampParams[1]
                hash = stampParams[2]
                
                myHash = calculateHash(params)
                
                #Evaluating Hash
                if (myHash != hash)
                  #Hash not valid
                  return false
                end
                
                #Evaluating Timestamp
                if ((Time.now.utc - Time.parse(timestamp).utc).to_int > (10*60))
                  #Timestamp not valid
                  return false
                end

                #Evaluating Password
                return ( password == SocialStream::Presence.xmpp_server_password )
              rescue
                return false
              end
            else
              #Basic authorization
              return ( params[:password] and params[:password] == SocialStream::Presence.xmpp_server_password )
            end
          end
          
          
          def calculateHash(params)
            #Require libraries
            require 'digest/md5'
            
            if params
              params.delete("password")
              params.delete("controller")
              params.delete("action")
            else
              params = {};
            end
            
            hash = "";
            params.each do |key,value|
              hash = hash + key.to_s + value.to_s
            end
            return Digest::MD5.hexdigest(hash)
          end
        
        
          def decryptParams(params)     
            case SocialStream::Presence.secure_rest_api
            when true
              #Secure Mode
              begin
                #Require libraries
                require 'openssl'
                
                if params[:encrypted_params]
                  presence_root = File.expand_path("../../../../", __FILE__)
                  web_private_key_path = presence_root + "/rsa_keys/web_rsa_key_private.pem";
                  private_key = OpenSSL::PKey::RSA.new(File.read(web_private_key_path))
                  
                  clear_params_hash_string = private_key.private_decrypt( params[:encrypted_params] )
                  clear_params = getHashFromHashString(clear_params_hash_string)
                  params.delete("encrypted_params")
                  
                  clear_params.each do |key,value|
                    params[key] = value
                  end
                end
              
                return params
              rescue
                return "Error in function: decryptParam(param)"
              end
              
            else
              #Non Secure Mode
              return params
            end
          end        
        
        
        

          ##################
          #  Help methods
          ##################
          
          def isEjabberdNodeUp
              output = executeEmanagementCommand("isEjabberdNodeStarted",[])
              nodeUp = output.split("\n")[0]
              return (nodeUp and nodeUp.strip()=="true")
          end
        
          def parsingCommand(command)
              #Hide passwords on sudo commands: command pattern = "echo password | sudo -S order"
              return command.gsub(/echo ([aA-zZ]+) [|] sudo -S [.]*/,"echo ****** | sudo -S \\2")
          end
          
          def getHashFromHashString(hashString)
            hash={}
            hashString[1..-2].split(/, /).each {|entry|
              entryMap=entry.split(/=>/); 
              value_str = entryMap[1]; 
              hash[entryMap[0].strip[1..-1].to_sym] = value_str.nil? ? "" : value_str.strip[1..-2]
            }
            return hash
          end
        
          
          
          
          ##################
          #  Multidomain tasks
          ##################
          
          def addWebDomain(domain,url)
            commands = []
            if url
              commands << buildCommand("manageWebDomains","add",[domain,url])
            else
              commands << buildCommand("manageWebDomains","add",[domain])
            end
            return executeCommands(commands) 
          end
          
          def removeWebDomain(domain)
            commands = []
            commands << buildCommand("manageWebDomains","remove",[domain])
            return executeCommands(commands) 
          end
        
          def updateWebDomain(domain,url)
            commands = []
            if url
              commands << buildCommand("manageWebDomains","update",[domain,url])
            else
              commands << buildCommand("manageWebDomains","update",[domain])
            end
            return executeCommands(commands)
          end
         
      end
    end
  end
end
