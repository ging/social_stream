module ConferenceManager
  class EventStatus < Resource
    singleton
   
    self.element_name = "event-status" 
    self.site = domain
    self.prefix = "/events/:event_id/"

  end
end
