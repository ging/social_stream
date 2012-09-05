require "net/http"
require "uri"

module SocialStream 
  module Ostatus
    module Models 
      module Actor
        extend ActiveSupport::Concern
        
        included do
          after_create :init_feeds_to_hub
        end
        
        module InstanceMethods
          def init_feeds_to_hub
            publish_or_update_public_feed
            #TO-DO: add calls to other public feeds if any
          end
          
          def publish_or_update_public_feed
            t = Thread.new do
              hub = Social2social.hub 
              topic = Social2social.node_base_url+'/api/user/'+self.slug+'/public.atom'
              
              uri = URI.parse(hub)
              response = Net::HTTP::post_form(uri,{ 'hub.mode' => 'publish',
                                                    'hub.url'  => topic})
              #TO-DO: process 4XX look at: response.status
            end
          end
        end
      end 
    end
  end
end
