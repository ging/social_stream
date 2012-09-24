class WebfingerController < ActionController::Metal
  include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  def index
    actor = Actor.find_by_webfinger!(params[:q])

    finger = Proudhon::Finger.new(
      :subject => actor.webfinger_uri,
      :alias   => [polymorphic_url(actor.subject)],
      :links   => {
        profile: polymorphic_url([actor.subject, :profile]),
        updates_from: polymorphic_url([actor.subject, :activities], :format => :atom),
        salmon: salmon_url(actor.slug),
        replies: salmon_url(actor.slug),
        mention: salmon_url(actor.slug),
        magic_key: actor.magic_public_key
      })

    self.response_body = finger.to_xml
    self.content_type  = Mime::XML
  end
end
