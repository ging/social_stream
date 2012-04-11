module SocialStream
  module Routing
    module Constraints
      class Custom
        def matches?(request)
          SocialStream.relation_model == :custom
        end
      end
    end
  end
end
