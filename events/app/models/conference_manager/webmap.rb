module ConferenceManager
  class Webmap < Resource
    singleton
    
    self.element_name = "webmap" 
    self.site = domain 
    self.prefix = "/events/:event_id/"
    self.format = ActiveResource::Formats::HtmlFormat

  end
end
