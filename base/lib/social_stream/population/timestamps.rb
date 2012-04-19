module SocialStream
  module Population
    class Timestamps
      attr_reader :created, :updated

      def initialize
        @updated = Time.at(rand(Time.now.to_i))
        @created = Time.at(rand(@updated.to_i))
      end
    end
  end
end
