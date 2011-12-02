#!/usr/bin/env ruby

def getOption(option)
  File.open('/etc/ejabberd/ssconfig.cfg', 'r') do |f1|  
    while line = f1.gets  
      line = line.gsub(/\n/,'')
      if line.match(/^#/)
        #Comments
      elsif line.match(/^#{option}/)
        return line.gsub(/#{option}/,'')
      end  
    end  
  end
  return "Undefined"
end

puts ""
puts "############### Ejabberd Configuration ###############"
puts "Config file for Social Stream Presence: /etc/ejabberd/ssconfig.cfg"
puts "Xmpp Server domain: #{getOption("server_domain=")}"
puts "Scripts Path: #{getOption("scripts_path=")}"
puts "mod_sspresence Path: #{getOption("source_path=")}"
puts "Web Domain for REST API: #{getOption("web_domain=")}"
puts "##############################"
puts "REST API"
puts "Authentication by password: http://#{getOption("web_domain=")}/users/sign_in"
puts "Authentication by cookie: http://#{getOption("web_domain=")}/api/me"
puts "onRegisterConnection: http://#{getOption("web_domain=")}/xmpp/setConnection"
puts "onRemoveConnection: http://#{getOption("web_domain=")}/xmpp/unsetConnection"
puts "onPresence: http://#{getOption("web_domain=")}/xmpp/setPresence"
puts "onUnsetPresence: http://#{getOption("web_domain=")}/xmpp/unsetPresence"
puts "ResetConnection: http://#{getOption("web_domain=")}/xmpp/resetConnection"
puts "SynchronizePresence: http://#{getOption("web_domain=")}/xmpp/synchronizePresence"
puts "##############################"
puts "Social Stream Presence logs in var/log/ejabberd/"
puts "######################################################"
puts ""
