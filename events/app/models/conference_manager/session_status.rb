module ConferenceManager
  class SessionStatus < Resource
    singleton
   
    self.element_name = "session-status" 
    self.site = domain
    self.prefix = "/events/:event_id/sessions/:session_id/" 

    def new?
      false      
    end
    
  end
end
