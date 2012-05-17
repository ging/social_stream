require File.expand_path("../lib/social_stream/release/component", __FILE__)

# SocialStream release tasks
class Release < Thor

  default_task :bump_and_publish

  desc "bump_and_publish", "Bump gem versions and release them"

  method_options :test => false

  def bump_and_publish(*args)
    bump *args
    publish *args
  end

  desc "bump", "Bump gem versions and set SocialStream's dependencies"

  method_options :test => false

  def bump(*args)
    # First of all, update gems
    system "bundle"

    parse_args_and_opts(args)

    all.each(&:bump)

    release_cmd("git commit #{ all.map(&:commit_files).join(" ") } -m #{ @global.version }")
  end

  desc "publish", "push SocialStream's gems to rubygems and create git tags"

  method_options :test => false

  def publish(*args)
    parse_args_and_opts(args)

    all.each(&:publish)
  end

  private

  def parse_args_and_opts(args)
    if options[:test]
      SocialStream::Release::Kernel.release_action = :test
    end

    releases =
      if args.empty?
        # base documents events ...
        global_dependencies.select{ |c|
          ::SocialStream::Release::Component.new(c).dirty?
        }
      elsif args.size == 1 && [ "major", "minor" ].include?(args.first)
        # base:minor documents:minor ... minor
        global_dependencies.map{ |c|
          "#{ c }:#{ args.first }"
        } + args 
      else
        # custom
        args
      end

    @components = []

    releases.each do |a|
      name, version = a.split(":")

      if global_dependencies.include?(name)
        @components << ::SocialStream::Release::Component.new(name, options.merge(:version => version))
      else
        @target = name
      end
    end

    @global = ::SocialStream::Release::Global.new(@target)
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
