module SocialStream
  module Population
    class Timestamps
      SCOPE = 1.month

      attr_reader :created, :updated

      def initialize
        created = rand(SCOPE)
        update = [ true, false ].sample
        updated = update ? rand(created) : created

        @created = Time.at(Time.now.to_i - created)
        @updated = Time.at(Time.now.to_i - updated)
      end
    end
  end
end
