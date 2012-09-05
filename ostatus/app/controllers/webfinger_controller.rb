class WebfingerController < ActionController::Metal
  include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  def index
    actor = Actor.find_by_webfinger!(params[:q])

    finger = Proudhon::Finger.new :links => {
      :profile => polymorphic_url([actor.subject, :profile])
    }

    self.response_body = finger.to_xml
    self.content_type  = Mime::XML
  end
end
