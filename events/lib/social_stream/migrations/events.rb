require 'social_stream/migrations/base'

module SocialStream
  module Migrations
    class Events < Base
      def initialize
        super

        @events = find_migration('social_stream-events')
      end

      def up(options = {})
        if options[:base]
          super
        end

        ActiveRecord::Migrator.migrate @events
      end

      def down
        ActiveRecord::Migrator.migrate @events, 0

        super
      end
    end
  end
end
