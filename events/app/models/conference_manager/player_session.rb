module ConferenceManager
  class PlayerSession < Resource
    singleton
   
    self.element_name = "player" 
    self.site = domain
    self.prefix = "/events/:event_id/sessions/:session_id/" 
    self.format = ActiveResource::Formats::HtmlFormat

  end
end
