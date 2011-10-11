require 'social_stream/migrations/base'

module SocialStream
  module Migrations
    class Components < Base
      def initialize
        @component = find_migration("social_stream-#{ self.class.name.split('::').last.underscore }")
      end

      def up(options = {})
        ActiveRecord::Migrator.migrate @component
      end

      def down(options = {})
        ActiveRecord::Migrator.migrate @component, 0
      end
    end
  end
end
