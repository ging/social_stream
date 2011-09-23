# SocialStream release tasks
class SocialStream < Thor
  include Thor::Actions

  # Manage component's version files
  #
  # This code is based on gem_release's version_file.rb
  # https://github.com/svenfuchs/gem-release
  #
  # Copyright (c) 2010 Sven Fuchs <svenfuchs@artweb-design.de>
  class VersionFile
    VERSION_PATTERN = /(VERSION\s*=\s*(?:"|'))(\d+\.\d+\.\d+)("|')/
    NUMBER_PATTERN = /(\d+)\.(\d+)\.(\d+)/

    attr_reader :component, :target

    def initialize(arg = "")
      @component, @target = arg.split(":")
      @target ||= :patch
    end

    def bump!
      # Must load content before writing to it
      content

      File.open(filename, 'w+') { |f| f.write(bumped_content) }

      commit

      [ component, new_number ]
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
      component ?
        "#{ component }/lib/social_stream/#{ component }/version.rb" :
        "lib/social_stream/version.rb"
    end

    def commit
      files = filename
      files += " social_stream.gemspec" if component.nil?

      system "git commit #{ files } -m #{ component }#{ new_number }"
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


  desc "release", "release SocialStream's gems"
  def release(*components)
    component_releases = components.map{ |c| release_component(c) }

    update_components(component_releases)

    VersionFile.new.bump!

    system "rake release"
  end

  private

  def release_component(component)
    component, version = VersionFile.new(component).bump!

    system "cd #{ component } && rake release"

    [ component, version ]
  end

  def update_components(releases)
    releases.each do |r|
      component, version = r

      gsub_file 'social_stream.gemspec',
                /social_stream-#{ component }.*(\d+\.\d+\.\d+)/,
                "social_stream-#{ component }', '~> #{ version }"
    end
  end
end
