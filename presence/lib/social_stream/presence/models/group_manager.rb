module SocialStream
  module Presence
    module Models
      module GroupManager
        extend ActiveSupport::Concern
        
        included do
          after_create :create_group_room
          after_destroy :remove_group_room
        end
        
        def create_group_room
          
          unless SocialStream::Presence.enable
            return
          end
          
          unless self.subject_type == "Group"
            return
          end 
          
          begin
            SocialStream::Presence::XmppServerOrder::createPersistentRoom(self.slug,SocialStream::Presence.domain)
          rescue Exception => e
            logger.warn ("WARNING Exeception in Group Manager create_group_room: " + e.message)
            puts ("WARNING Exeception in Group Manager create_group_room: " + e.message)
          end
        end
        
        
        def remove_group_room
           
            unless SocialStream::Presence.enable
              return
            end
            
            unless self.subject_type == "Group"
              return
            end
            
            begin
              SocialStream::Presence::XmppServerOrder::destroyRoom(self.slug,SocialStream::Presence.domain)
            rescue Exception => e 
              logger.warn ("WARNING Exeception in Group Manager remove_group_room: " + e.message)
              puts ("WARNING Exeception in Group Manager remove_group_room: " + e.message)
            end
        end
      end
    end
  end
end
