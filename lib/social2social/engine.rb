module Social2social
  class Engine < Rails::Engine
    config.app_generators.social_stream :social_stream

    config.to_prepare do
      SocialStream.subjects << :remote_user
      ::Actor.load_subtype_features
      
      class ::Actor
        include Social2social::Models::Shareable
      end
      
      TieActivity      
      
      class ::TieActivity
        include Social2social::Models::UpdateTriggerable
      end
    end
        
  end
end