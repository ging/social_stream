module SocialStream
  module Ostatus
    class Engine < Rails::Engine
      initializer 'social_stream-ostatus.actor' do
        ActiveSupport.on_load(:actor) do
          include SocialStream::Ostatus::Models::Actor
        end
      end

      initializer 'social_stream-ostatus.audience' do
        ActiveSupport.on_load(:audience) do
          include SocialStream::Ostatus::Models::Audience
        end
      end

      initializer "social_stream-ostatus.remote_subject_in_social_stream_subjects" do
        SocialStream.subjects << :remote_subject unless SocialStream.subjects.include?(:remote_subject)
      end

      initializer "social_stream-ostatus.remote_subject.default_relations" do
        Relation::Custom::DEFAULT['remote_subject'] = {
          'default' => {
            'name' => 'default',
            'permissions' => [
              [ 'read', 'activity' ]
            ]
          }
        }
      end
    end
  end
end
