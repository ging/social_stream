require File.expand_path('../kernel', __FILE__)
require File.expand_path('../dependency_update', __FILE__)
require File.expand_path('../global/version_file', __FILE__)

module SocialStream
  module Release
    class Global
      include Thor::Actions

      DEPENDENCY_REGEXP = /dependency.*social_stream-(\w*)/

      attr_reader :name, :version

      def initialize(target = nil)
        @target = target
      end
      
      def bump
        bump_version

        update_dependencies
      end

      def publish
        release_cmd rake_release_command
      end

      def dependencies
        @dependencies ||=
          File.read(gemspec).scan(DEPENDENCY_REGEXP).flatten
      end

      def commit_files
        "#{ @version_file.filename } #{ gemspec }"
      end

      def last_tag
        `git describe`.split('-').first
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
