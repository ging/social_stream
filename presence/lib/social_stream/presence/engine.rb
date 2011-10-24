module SocialStream
  module Presence
    class Engine < Rails::Engine
      config.to_prepare do
        
        #Patching Tie
        Tie.class_eval do
          include SocialStream::Presence::Models::BuddyManager
        end
        
      end 
 
    end
  end
end
