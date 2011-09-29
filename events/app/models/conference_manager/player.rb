module ConferenceManager
  class Player < Resource
    singleton
    
    self.element_name = "player" 
    self.site = domain 
    self.prefix = "/events/:event_id/"
    self.format = ActiveResource::Formats::HtmlFormat

  end
end
