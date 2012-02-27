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
puts "Scripts Path: #{getOption("scripts_path=")}"
puts "mod_sspresence Path: #{getOption("source_path=")}"
puts "Web Server domains: #{getOption("web_domains=")}"
puts "##############################"
puts "REST API"
puts "Authentication by password: http://domainURL/users/sign_in"
puts "Authentication by cookie: http://domainURL/api/me"
puts "onRegisterConnection: http://domainURL/xmpp/setConnection"
puts "onRemoveConnection: http://domainURL/xmpp/unsetConnection"
puts "onPresence: http://domainURL/xmpp/setPresence"
puts "onUnsetPresence: http://domainURL/xmpp/unsetPresence"
puts "ResetConnection: http://domainURL/xmpp/resetConnection"
puts "SynchronizePresence: http://domainURL/xmpp/synchronizePresence"
puts "##############################"
puts "Social Stream Presence logs in var/log/ejabberd/"
puts "######################################################"
puts ""
