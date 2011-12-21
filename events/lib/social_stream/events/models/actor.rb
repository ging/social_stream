module SocialStream
  module Events
    module Models
      module Actor
        extend ActiveSupport::Concern

        included do
          has_many :rooms
        end
      end
    end
  end
end
