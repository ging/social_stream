module SocialStream
  module Ostatus
    module Models
      module Object
        module ClassMethods
          # Creates an new instance from ActivityStreams entry
          #
          def from_entry! entry
            create! do |obj|
              obj.author =
                obj.user_author =
                obj.owner =
                SocialStream::ActivityStreams.actor_from_entry! entry

              obj.title = entry.title
              obj.description = entry.content

              obj.relation_ids = [ Relation::Public.instance.id ]

              yield obj if block_given?
            end
          end
        end
      end
    end
  end
end
