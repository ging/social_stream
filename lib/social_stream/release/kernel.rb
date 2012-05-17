module SocialStream
  module Release
    module Kernel
      class << self
        attr_accessor :release_action
      end

      @release_action = :system
    end
  end
end

module Kernel
  def release_cmd(cmd)
    case SocialStream::Release::Kernel.release_action
    when :system
      system(cmd) || raise(RuntimeError.new)
    when :test
      puts "* release_cmd * #{ cmd }"
    else
      raise "Unknown release_action #{ SocialStream::Release::Kernel.release_action }"
    end
  end
end
