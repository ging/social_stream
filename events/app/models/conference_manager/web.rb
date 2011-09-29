module ConferenceManager
  class Web < Resource
    singleton

    self.element_name = "web" 
    self.site = domain
    self.prefix = "/events/:event_id/" 
    self.format = ActiveResource::Formats::HtmlFormat
    
  end
end
