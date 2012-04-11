module SocialStream
  module Routing
    module Constraints
      class Follow
        def matches?(request)
          SocialStream.relation_model == :follow
        end
      end
    end
  end
end
