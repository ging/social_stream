module ConferenceManager
  class Event < Resource
    
    self.element_name = "event"
    self.site = domain
    
    def enable_sip?
      enable_sip == "true"
    end
    
    def enable_isabel?
      enable_isabel == "true"
    end
    
    def enable_web?
      enable_web =="true"
    end
    
    def enable_httplivestreaming?
      enable-httplivestreaming == "true"  
    end
    
  end
end
