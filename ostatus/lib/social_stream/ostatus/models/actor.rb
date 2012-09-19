require "net/http"
require "uri"

module SocialStream 
  module Ostatus
    module Models 
      module Actor
        extend ActiveSupport::Concern

        include Rails.application.routes.url_helpers
        
        included do
          has_one :actor_key, dependent: :destroy,
                              validate:  true,
                              autosave:  true

          after_commit :publish_feed
        end

        module ClassMethods
          # Extract the slug from the webfinger id and return the actor
          # searching by that slug
          def find_by_webfinger!(link)
            link =~ /(acct:)?(.*)@/

            find_by_slug! $2
          end
        end

        # The Webfinger ID for this {Actor}
        def webfinger_id
          "#{ slug }@#{ SocialStream::Ostatus.activity_feed_host }"
        end

        # The Webfinger URI for this {Actor}
        def webfinger_uri
          "acct:#{ webfinger_id }"
        end

        # Fetch or create the associated {ActorKey}
        def actor_key!
          actor_key ||
            create_actor_key!
        end

        # OpenSSL::PKey::RSA key
        #
        # The key is generated if it does not exist
        def rsa_key
          actor_key!.key
        end

        # Set OpenSSL::PKey::RSA key
        def rsa_key= key
          k = actor_key || build_actor_key
          k.key = key
        end

        # Public RSA instance of {#rsa_key}
        def rsa_public_key
          rsa_key.public_key
        end

        # MagicKey string from public key
        def magic_public_key
          Proudhon::MagicKey.to_s rsa_public_key
        end

        def publish_feed
          return if subject_type == "RemoteSubject"

          # FIXME: Rails 4 queues
          Thread.new do
            uri = URI.parse(SocialStream::Ostatus.hub)
            topic = polymorphic_url [subject, :activities],
                                    :format => :atom,
                                    :host => SocialStream::Ostatus.activity_feed_host
            
            response = Net::HTTP::post_form uri, { 'hub.mode' => 'publish',
                                                   'hub.url'  => topic }
            #TODO: process 4XX look at: response.status

            ActiveRecord::Base.connection.close
          end
        end
      end 
    end
  end
end
