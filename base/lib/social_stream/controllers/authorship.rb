module SocialStream
  module Controllers
    module Authorship
      extend ActiveSupport::Concern

      included do
        before_filter :set_author_ids, only: [ :new, :create ]
      end

      private

      def set_author_ids
        resource_params.first[:author_id]      = current_subject.try(:actor_id)
        resource_params.first[:user_author_id] = current_user.try(:actor_id)
        resource_params.first[:owner_id]       ||= current_subject.try(:actor_id)
      end
    end
  end
end
