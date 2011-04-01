module Social2social 
  
  class S2Srailtie < Rails::Railtie
    
    config.to_prepare do
      class ::Actor
        include Social2social::Models::Shareable
      end
      
      class ::TieActivity
        #include Social2social::Models::UpdateTriggerable
      end
    end
    
  end
  
end
