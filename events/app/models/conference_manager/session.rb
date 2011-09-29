module ConferenceManager
  class Session < Resource
    self.element_name = "session" 
    self.site = domain
    self.prefix = "/events/:event_id/"
    
    def recording?
      recording == "true"
    end  
    
    def streaming?
      streaming == "true"
    end
  end
end
