module SocialStream
  module Release
    class Global
      # Manage component's version files
      #
      # This code is based on gem_release's version_file.rb
      # https://github.com/svenfuchs/gem-release
      #
      # Copyright (c) 2010 Sven Fuchs <svenfuchs@artweb-design.de>
      class VersionFile
        VERSION_PATTERN = /(VERSION\s*=\s*(?:"|'))(\d+\.\d+\.\d+)("|')/
        NUMBER_PATTERN = /(\d+)\.(\d+)\.(\d+)/

        attr_reader :target

        def initialize(target)
          @target = target || :patch
        end

        def bump!
          # Must load content before writing to it
          content

          File.open(filename, 'w+') { |f| f.write(bumped_content) }

          new_number
        end

        def new_number
          @new_number ||= old_number.sub(NUMBER_PATTERN) do
            respond_to?(target) ? send(target, $1, $2, $3) : target
          end
        end

        def old_number
          @old_number ||= content =~ VERSION_PATTERN && $2
        end

        def filename
          "lib/social_stream/version.rb"
        end

        protected

        def major(major, minor, patch)
          "#{major.to_i + 1}.0.0"
        end

        def minor(major, minor, patch)
          "#{major}.#{minor.to_i + 1}.0"
        end

        def patch(major, minor, patch)
          "#{major}.#{minor}.#{patch.to_i + 1}"
        end

        def content
          @content ||= File.read(filename)
        end

        def bumped_content
          content.sub(VERSION_PATTERN) { "#{$1}#{new_number}#{$3}" }
        end
      end
    end
  end
end

