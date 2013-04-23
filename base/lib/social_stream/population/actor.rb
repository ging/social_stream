module SocialStream
  module Population
    module Actor
      class << self
        def demo
          @demo ||=
            ::Actor.where(slug: "demo").first
        end

        def available
          load_available.dup
        end

        private

        def load_available
          @load_available ||= ::Actor.all
        end
      end
    end
  end
end
