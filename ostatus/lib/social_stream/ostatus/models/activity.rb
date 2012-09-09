module SocialStream
  module Ostatus
    module Models 
      module Activity
        extend ActiveSupport::Concern

        module ClassMethods
          def from_entry(entry)
          end
        end
      end
    end
  end
end
