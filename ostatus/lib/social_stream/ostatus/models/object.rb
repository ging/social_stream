module SocialStream
  module Ostatus
    module Models
      module Object
        module ClassMethods
          # Creates an new instance from ActivityStreams entry
          #
          def from_entry! entry
            obj = new

            obj.author =
              obj.user_author =
              obj.owner =
              SocialStream::ActivityStreams.actor_from_entry! entry

            obj.title = e.title
            obj.description = e.description

            yield obj if block_given?

            obj.save!
          end
        end
      end
    end
  end
end
