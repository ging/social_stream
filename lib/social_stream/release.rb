module SocialStream
  module Release
    class << self
      def create(*args)
        # First of all, update gems
        system "bundle"

        parse_args(args)

        all.each(&:bump_version)

        all.each(&:update_dependencies)

        system("git commit #{ all.map(&:commit_files).join(" ") } -m #{ @global.version }") ||
          raise(RuntimeError.new)

        all.each(&:rake_release)
      end

      def dependencies
        @dependencies ||=
          Global::Release.new.dependencies
      end

      def parse_args args
        @components = []

        args.each do |a|
          name, version = a.split(":")

          if dependencies.include?(name)
            @components << Component::Release.new(name, version)
          else
            @target = name
          end
        end

        @global = Global::Release.new(@target)
      end

      def all
        @components + [ @global ]
      end
    end
  end
end

%w(dependency_update global/release global/version_file component/release component/version_file).each do |file|
  require File.expand_path("../release/#{ file }", __FILE__)
end

