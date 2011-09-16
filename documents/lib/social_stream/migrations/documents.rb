require 'social_stream/migrations/base'

module SocialStream
  module Migrations
    class Documents < Base
      def initialize
        super

        @documents = find_migration('social_stream-documents')
      end

      def up
        super

        ActiveRecord::Migrator.migrate @documents
      end

      def down
        ActiveRecord::Migrator.migrate @documents, 0

        super
      end
    end
  end
end
