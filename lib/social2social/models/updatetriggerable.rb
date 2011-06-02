module Social2social 
  module Models 
    module UpdateTriggerable
      extend ActiveSupport::Concern
      
      included do
        after_create :update_feed_to_hub
      end
      
      module InstanceMethods
        def update_feed_to_hub
          if original?
            if tie.relation.is_a?(Relation::Public)
              tie.sender.publish_or_update_public_feed
	    end
          end
        end
      end
      
    end
  end
end
