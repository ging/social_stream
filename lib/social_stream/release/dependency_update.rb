module SocialStream
  module Release
    class DependencyUpdate < Thor
      include Thor::Actions

      desc :update, "Update gemfile's dependency with some version"
      def update gemspec, dependency, version
        gsub_file gemspec,
                  /social_stream-#{ dependency }.*(\d+\.\d+\.\d+)/,
                  "social_stream-#{ dependency }', '~> #{ version }"
      end
    end
  end
end
