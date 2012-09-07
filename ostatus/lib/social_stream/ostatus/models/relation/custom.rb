module SocialStream
  module Ostatus
    module Models
      module Relation
        module Custom
          extend ActiveSupport::Concern

          included do
            const_get("DEFAULT")['remote_subject'] = {
              'default' => {
                'name' => 'default',
                'permissions' => [
                  [ 'read', 'activity' ]
                ]
              }
            }
          end
        end
      end
    end
  end
end
