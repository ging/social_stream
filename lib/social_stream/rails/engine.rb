require 'social_stream/rails/common'

module SocialStream
  module Rails
    class Engine < ::Rails::Engine #:nodoc:
      include Common
    end
  end
end
