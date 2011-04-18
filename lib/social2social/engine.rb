module Social2social
  class Engine < Rails::Engine
    config.app_generators.social_stream :social_stream

    config.to_prepare do
      #Loading RemoteUser as SocialStream Subject
      SocialStream.subjects << :remote_user
      ::Actor.load_subtype_features
      
      #Patching Actor
      class ::Actor
        include Social2social::Models::Shareable
      end
      
      #Forcing preload of TieActivity
      TieActivity      
      
      #Patching TieAct
      class ::TieActivity
        include Social2social::Models::UpdateTriggerable
      end
    end
        
  end
end