module SocialStream
  module Release
    class << self
      def create(*args)
        # First of all, update gems
        system "bundle"

        dependencies = Global::Release.new.dependencies

        components = args.map do |a|
          name, version = a.split(":")

          if dependencies.include?(name)
            Component::Release.new(name, version).release!
          else
            @target = name
          end
        end

        Global::Release.new(@target).release!
      end
    end
  end
end

%w(dependency_update global/release global/version_file component/release component/version_file).each do |file|
  require File.expand_path("../release/#{ file }", __FILE__)
end

