module ConferenceManager
  class Streaming < Resource
    singleton
    
    self.element_name = "streaming" 
    self.site = domain
    self.prefix = "/events/:event_id/"
    self.format = ActiveResource::Formats::HtmlFormat

  end
end
