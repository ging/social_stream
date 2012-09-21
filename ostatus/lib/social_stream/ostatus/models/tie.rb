module SocialStream
  module Ostatus
    module Models
      module Tie
        extend ActiveSupport::Concern

        module ClassMethods
          # Create a new {Tie} from OStatus entry
          def from_entry! entry, receiver
            # Sender must be remote
            sender = RemoteSubject.find_or_create_by_webfinger_uri! entry.author.uri

            contact = sender.contact_to!(receiver)

            # FIXME: hack
            contact.user_author = sender
            
            contact.relation_ids = [::Relation::Public.instance.id]
          end
        end
      end
    end
  end
end
