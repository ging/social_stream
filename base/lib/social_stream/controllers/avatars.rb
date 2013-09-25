module SocialStream
  module Controllers
    module Avatars
      extend ActiveSupport::Concern

      included do
        def current_avatarable
          @current_avatarable ||=
            Actor.find(params[:actor_id])
        end
      end
    end
  end
end
