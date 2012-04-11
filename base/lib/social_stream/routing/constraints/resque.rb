module SocialStream
  module Routing
    module Constraints
      class Resque
        def matches?(request)
          SocialStream.resque_access
        end
      end
    end
  end
end
