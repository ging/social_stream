module Social2social
  class Engine < Rails::Engine
    config.app_generators.social_stream :social_stream

    config.to_prepare do
      #Patching Actor
      Actor.class_eval do
        include Social2social::Models::Shareable
      end
      
      #Patching TieAct
      TieActivity.class_eval do
        include Social2social::Models::UpdateTriggerable
      end
    end

    initializer "social2social.remote_subject_in_social_stream_subjects" do
      SocialStream.subjects << :remote_subject unless SocialStream.subjects.include?(:remote_subject)
    end
  end
end
