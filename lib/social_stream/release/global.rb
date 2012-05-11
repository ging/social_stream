require File.expand_path('../dependency_update', __FILE__)
require File.expand_path('../global/version_file', __FILE__)

module SocialStream
  module Release
    class Global
      include Thor::Actions

      DEPENDENCY_REGEXP = /dependency.*social_stream-(\w*)/

      attr_reader :name, :version

      def initialize(target = nil, options = {})
        @target, @options = target, options
      end
      
      def bump
        bump_version

        update_dependencies
      end

      def publish
        if @options[:test]
          puts rake_release_command
        else
          system(rake_release_command) || raise(RuntimeError.new)
        end
      end

      def dependencies
        @dependencies ||=
          File.read(gemspec).scan(DEPENDENCY_REGEXP).flatten
      end

      def commit_files
        "#{ @version_file.filename } #{ gemspec }"
      end

      protected

      def bump_version
        @version = version_file.bump!
      end

      def version_file
        @version_file ||= VersionFile.new(@target)
      end

      def update_dependencies
        dependencies.each do |d|
          DependencyUpdate.new.invoke(:update, [ gemspec, d, Component::VersionFile.new(d).old_number ])
        end
      end

      def gemspec
        "social_stream.gemspec"
      end

      def rake_release_command
        "rake release"
      end
    end
  end
end
