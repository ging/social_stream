module SocialStream
  module Release
    module Global
      class Release
        include Thor::Actions

        DEPENDENCY_REGEXP = /dependency.*social_stream-(\w*)/

        attr_reader :name, :version

        def initialize(target = nil)
          @target = target
        end
        
        def release!
          bump_version

          update_dependencies

          commit

          rake_release
        end

        def bump_version
          @version = version_file.bump!
        end

        def version_file
          @version_file ||= VersionFile.new(@target)
        end

        def dependencies
          @dependencies ||=
            File.read(gemspec).scan(DEPENDENCY_REGEXP).flatten
        end

        def update_dependencies
          dependencies.each do |d|
            DependencyUpdate.new.invoke(:update, [ gemspec, d, Component::VersionFile.new(d).old_number ])
          end
        end

        def gemspec
          "social_stream.gemspec"
        end

        def commit
          system(commit_command) || raise(RuntimeError.new)
        end

        def commit_command
          "git commit #{ commit_files } -m #{ @version }"
        end

        def commit_files
          "#{ @version_file.filename } #{ gemspec }"
        end

        def rake_release
          system(rake_release_command) || raise(RuntimeError.new)
        end

        def rake_release_command
          "rake release"
        end
      end
    end
  end
end
