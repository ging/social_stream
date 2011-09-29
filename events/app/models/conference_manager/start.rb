module ConferenceManager
  class Start < Resource
    singleton

    self.element_name = "restart" 
    self.site = domain
    self.prefix = "/events/:event_id/"
  end   
end
