class RemoteSubject < ActiveRecord::Base
  include SocialStream::Models::Subject
  # Create absolute routes
  include Rails.application.routes.url_helpers

  attr_reader :url_helper
  attr_accessible :webfinger_id

  # Save webfinger_info hash into the database
  serialize :webfinger_info

  before_validation :fill_information,
                    :on => :create

  after_create  :suscribe_to_public_feed
  after_destroy :unsuscribe_to_public_feed
  
  #validates_format_of :webfinger_slug, :with => Devise.email_regexp, :allow_blank => true
  
  class << self
    def find_or_create_using_webfinger_id(id)
      subject = RemoteSubject.find_by_webfinger_id(id)

      return subject if subject.present?

      create! :webfinger_id => id
    end
  end
  
  # Return the slug in the webfinger_id
  def webfinger_slug
    splitted_webfinger_id.first
  end

  # Return the origin url in the webfinger_id
  def webfinger_url
    splitted_webfinger_id.last
  end

  # URL of the activity feed from this {RemoteSubject}
  def public_feed_url
    webfinger_info[:updates_from]
  end

  private

  def splitted_webfinger_id
    @splitted_webfinger_id ||=
      webfinger_id.split('@')
  end

  def fill_information
    self.webfinger_info = build_webfinger_info
    self.name = webfinger_id
  end

  def build_webfinger_info
    {
      :updates_from => finger.links[:updates_from]
    }
  end

  def finger
    @finger ||=
      fetch_finger
  end

  def fetch_finger
    Proudhon::Finger.fetch webfinger_id
  end

  def suscribe_to_public_feed
    return if public_feed_url.blank?

    atom = Proudhon::Atom.from_uri(public_feed_url)

    atom.subscribe(pshb_callback_url(:host => SocialStream::Ostatus.pshb_host))
  end

  def unsuscribe_to_public_feed
    return if public_feed_url.blank?

    atom = Proudhon::Atom.from_uri(public_feed_url)

    atom.unsubscribe(pshb_callback_url(:host => SocialStream::Ostatus.pshb_host))
  end
end
