module SocialStream
  module Events
    module Models
      module Actor
        extend ActiveSupport::Concern

        included do
          has_many :rooms
        end

        def events
          Event.authored_by(self)
        end
      end
    end
  end
end
