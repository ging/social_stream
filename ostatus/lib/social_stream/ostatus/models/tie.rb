module SocialStream
  module Ostatus
    module Models
      module Tie
        extend ActiveSupport::Concern

        module ClassMethods
          # Create a new {Tie} from OStatus entry
          def from_entry! entry, receiver
            # Sender must be remote
            sender = RemoteSubject.find_or_create_by_webfinger_id entry.author.uri

            sender.contact_to!(receiver).relation_ids = [Relation::Public.instance.id]
          end
        end
      end
    end
  end
end
