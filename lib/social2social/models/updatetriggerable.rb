module Social2social 
  module Models 
    module UpdateTriggerable
      extend ActiveSupport::Concern
      
      included do
        after_create :update_feed_to_hub
      end
      
      module InstanceMethods
        def update_feed_to_hub
          if self.original
            self.tie.sender.publish_or_update_home_feed
          end
        end
      end
      
    end
  end
end
