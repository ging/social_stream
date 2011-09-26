module SocialStream
  module Release
    module Component
      class Release < ::SocialStream::Release::Global::Release
        attr_reader :name

        def initialize(name, version)
          @name, @target = name, version
        end

        def version_file
          @version_file ||= Component::VersionFile.new(@name, @target)
        end

        def gemspec
          "#{ name }/social_stream-#{ name }.gemspec"                                           
        end

        def commit_command
          "git commit #{ commit_files } -m #{ @name }#{ @version }"
        end

        def rake_release_command
          "cd #{ @name } && rake release"
        end
      end
    end
  end
end
