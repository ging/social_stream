module SocialStream
  module Population
    class << self
      def task message
        puts message
        time = Time.now

        yield

        puts "   -> #{ (Time.now - time).round(4) }s"
      end
    end
  end
end
