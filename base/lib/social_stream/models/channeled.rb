module SocialStream
  module Models
    # Models that have author, user_author and owner, properties saved in {Channel}.
    # Currently {Activity} and {ActivityObject}
    module Channeled
      # Add the method {#channeled} to ActiveRecord
      module ActiveRecord
        extend ActiveSupport::Concern

        module ClassMethods
          # This class is channeled. See {Channel}
          def channeled
            include SocialStream::Models::Channeled
          end
        end
      end

      extend ActiveSupport::Concern

      included do
        # Channeled models are subtypes of {Channel}
        # Author, owner and user_author are defined in its channel
        subtype_of :channel,
                   :belongs => { :dependent => nil }

        # before_validation :set_owner_id, :on => :create

        before_validation :check_existing_channel
      end

      protected

      # Use existing channel, do not create a new one
      def check_existing_channel
        return unless channel!.new_record?

        existing_channel =
          Channel.
            where(:author_id      => author_id,
                  :owner_id       => owner_id,
                  :user_author_id => user_author_id).
            first

        return if existing_channel.blank?

        self.channel = existing_channel
      end

      private

      def set_owner_id
        self.owner_id ||= author_id
      end
    end
  end
end
