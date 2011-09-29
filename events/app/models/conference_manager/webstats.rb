module ConferenceManager
  class Webstats < Resource
    singleton
    
    self.element_name = "webstat" 
    self.site = domain 
    self.prefix = "/events/:event_id/"
    self.format = ActiveResource::Formats::HtmlFormat

  end
end
