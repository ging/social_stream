require File.expand_path("../lib/social_stream/release/component", __FILE__)

# SocialStream release tasks
class Release < Thor

  default_task :bump_and_publish

  method_option :test => false,
                :desc => "Do nothing",
                :aliases => "-t"

  desc "bump_and_publish", "Bump gem versions and release them"
  def bump_and_publish(*args)
    bump *args
    publish *args
  end

  desc "bump", "Bump gem versions and set SocialStream's dependencies"
  def bump(*args)
    # First of all, update gems
    system "bundle"

    parse_args(args)

    all.each(&:bump)

    system("git commit #{ all.map(&:commit_files).join(" ") } -m #{ @global.version }") ||
      raise(RuntimeError.new)
  end

  desc "publish", "push SocialStream's gems to rubygems and create git tags"
  def publish(*args)
    parse_args(args)

    all.each(&:publish)
  end

  private

  def parse_args(args)
    if args.empty?
      args = global_dependencies
    end

    @components = []

    args.each do |a|
      name, version = a.split(":")

      if global_dependencies.include?(name)
        @components << ::SocialStream::Release::Component.new(name, options.merge(:version => version))
      else
        @target = name
      end
    end

    @global = ::SocialStream::Release::Global.new(@target, options)
  end

  def global_dependencies
    @global_dependencies ||=
      ::SocialStream::Release::Global.new.dependencies
  end

  def all
    @all ||=
      @components + [@global]
  end
end
