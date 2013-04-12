module SocialStream
  module Controllers
    # Common methods added to ApplicationController
    module MarkNotificationsRead
      extend ActiveSupport::Concern

      included do
         before_filter :mark_notifications_read
      end

      # Mark notifications read when following a link
      def mark_notifications_read
        return if params[:notification_id].blank? or !user_signed_in?
        n = Notification.find(params[:notification_id])
        current_subject.mark_as_read n
      end
    end
  end
end
