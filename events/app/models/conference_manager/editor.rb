module ConferenceManager
  class Editor < Resource
    singleton

    self.element_name = "editor" 
    self.site = domain
    self.prefix = "/events/:event_id/" 
    self.format = ActiveResource::Formats::HtmlFormat

  end
end
