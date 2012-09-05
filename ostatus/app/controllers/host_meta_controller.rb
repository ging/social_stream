class HostMetaController < ActionController::Metal
  include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  def index
    self.response_body = Proudhon::HostMeta.to_xml("#{ webfinger_url }?q={uri}")
    self.content_type  = Mime::XML
  end
end
