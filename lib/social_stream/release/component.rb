require File.expand_path('../global', __FILE__)

module SocialStream
  module Release
    class Component < Global
      attr_reader :name

      def initialize(name, options = {})
        @name, @options = name, options
      end

      protected

      def version_file
        @version_file ||= VersionFile.new(@name, @options[:version])
      end

      def gemspec
        "#{ name }/social_stream-#{ name }.gemspec"                                           
      end

      def rake_release_command
        "cd #{ @name } && rake release"
      end
    end
  end
end

require File.expand_path('../component/version_file', __FILE__)
