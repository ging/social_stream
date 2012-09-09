module SocialStream
  module Ostatus
    module Models 
      module Audience
        extend ActiveSupport::Concern
        
        included do
          after_create :update_feed_to_hub
        end
        
        def update_feed_to_hub
          if relation.is_a?(::Relation::Public)
            activity.owner.publish_feed
          end
        end
      end
    end
  end
end
