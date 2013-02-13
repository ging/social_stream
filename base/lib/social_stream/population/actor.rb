module SocialStream
  module Population
    module Actor
      class << self
        def demo
          @demo ||=
            ::Actor.where(slug: "demo").first
        end
      end
    end
  end
end
