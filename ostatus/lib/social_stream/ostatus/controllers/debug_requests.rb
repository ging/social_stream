module SocialStream
  module Ostatus
    module Controllers
      module DebugRequests
        extend ActiveSupport::Concern

        included do
          before_filter :debug_request
        end

        private

        def debug_request
          return unless SocialStream::Ostatus.debug_requests

          logger.info request.body.read

          # Set StringIO to initial state for the action to get the content
          request.body.rewind
        end
      end
    end
  end
end
