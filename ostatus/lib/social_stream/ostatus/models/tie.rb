module SocialStream
  module Ostatus
    module Models
      module Tie
        extend ActiveSupport::Concern

        module ClassMethods
          # Create a new {Tie} from OStatus entry
          def create_from_entry! entry, receiver
            contact = Contact.from_entry! entry, receiver
           
            contact.relation_ids = [::Relation::Public.instance.id]
          end

          # Remove all {Tie} from OStatus entry
          def destroy_from_entry! entry, receiver
            contact = Contact.from_entry! entry, receiver

            contact.relation_ids = []
          end
        end
      end
    end
  end
end
