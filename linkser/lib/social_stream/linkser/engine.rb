module SocialStream
  module Linkser
    class Engine < Rails::Engine
    
      initializer 'social_stream-linkser.models.register_activity_streams' do
        SocialStream::ActivityStreams.register :bookmark, :link
      end
    end
  end
end
