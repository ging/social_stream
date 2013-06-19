module SocialStream
  module Ostatus
    class Engine < Rails::Engine
      initializer 'social_stream-ostatus.activity_streams' do
        SocialStream::ActivityStreams.class_eval do
          extend SocialStream::Ostatus::ActivityStreams
        end
      end

      initializer 'social_stream-ostatus.models.object' do
        SocialStream::Models::Object::ClassMethods.module_eval do
          include SocialStream::Ostatus::Models::Object::ClassMethods
        end
      end

      initializer "social_stream-ostatus.remote_subject_in_social_stream_subjects" do
        SocialStream.subjects << :remote_subject unless SocialStream.subjects.include?(:remote_subject)
      end

      initializer "social_stream-ostatus.custom_relations" do
        SocialStream.custom_relations['remote_subject'] = {
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
