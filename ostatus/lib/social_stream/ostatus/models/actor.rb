require "net/http"
require "uri"

module SocialStream 
  module Ostatus
    module Models 
      module Actor
        extend ActiveSupport::Concern

        include Rails.application.routes.url_helpers
        
        included do
          after_create :publish_feed
        end

        module ClassMethods
          # Extract the slug from the webfinger id and return the actor
          # searching by that slug
          def find_by_webfinger!(link)
            link =~ /(acct:)?(.*)@/

            find_by_slug! $2
          end
        end
        
        def publish_feed
          return if subject_type == "RemoteSubject"

          t = Thread.new do
            uri = URI.parse(SocialStream::Ostatus.hub)
            topic = polymorphic_url [subject, :activities],
                                    :format => :atom,
                                    :host => SocialStream::Ostatus.activity_feed_host
            
            response = Net::HTTP::post_form uri, { 'hub.mode' => 'publish',
                                                   'hub.url'  => topic }
            #TO-DO: process 4XX look at: response.status
          end
        end
      end 
    end
  end
end
