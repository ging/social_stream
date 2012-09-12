module SocialStream
  module Ostatus
    class Engine < Rails::Engine
      initializer 'social_stream-ostatus.activity_streams' do
        SocialStream::ActivityStreams.class_eval do
          extend SocialStream::Ostatus::ActivityStreams
        end
      end

      initializer 'social_stream-ostatus.models.actor' do
        ActiveSupport.on_load(:actor) do
          include SocialStream::Ostatus::Models::Actor
        end
      end

      initializer 'social_stream-ostatus.models.audience' do
        ActiveSupport.on_load(:audience) do
          include SocialStream::Ostatus::Models::Audience
        end
      end

      initializer 'social_stream-ostatus.models.object' do
        SocialStream::Models::Object::ClassMethods.module_eval do
          include SocialStream::Ostatus::Models::Object::ClassMethods
        end
      end

      initializer 'social_stream-ostatus.models.relation_custom' do
        ActiveSupport.on_load(:relation_custom) do
          include SocialStream::Ostatus::Models::Relation::Custom
        end
      end

      initializer "social_stream-ostatus.remote_subject_in_social_stream_subjects" do
        SocialStream.subjects << :remote_subject unless SocialStream.subjects.include?(:remote_subject)
      end
    end
  end
end
