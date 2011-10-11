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
puts "API REST URLs"
puts "Authentication: #{getOption("auth_api=")}"
puts "onRegisterConnection: #{getOption("set_connection_api=")}"
puts "onRemoveConnection: #{getOption("unset_connection_api=")}"
puts "onPresence: #{getOption("set_presence_api=")}"
puts "onUnsetPresence: #{getOption("unset_presence_api=")}"
puts "Social Stream Presence logs in var/log/ejabberd/"
puts "######################################################"
puts ""
