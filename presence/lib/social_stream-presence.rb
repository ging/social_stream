require 'social_stream-base'

module SocialStream
  module Presence   

    module Models
      autoload :BuddyManager, 'social_stream/presence/models/buddy_manager'
    end

  end
end

require 'social_stream/presence/engine'