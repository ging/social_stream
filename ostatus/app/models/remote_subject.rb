class RemoteSubject < ActiveRecord::Base
  include SocialStream::Models::Subject

  attr_accessible :webfinger_id

  before_validation :fill_information,
                    :on => :create
  
  #validates_format_of :webfinger_slug, :with => Devise.email_regexp, :allow_blank => true
  
  class << self
    def find_or_create_using_webfinger_id(id)
      subject = RemoteSubject.find_by_webfinger_id(id)

      return subject if subject.present?

      begin
        finger = Proudhon::Finger.fetch id
      rescue
        raise ActiveRecord::RecordNotFound
      end

      create! :webfinger_id => id
    end
  end
  
  # Public feed url for this RemoteSubject
  #
  # TODO: get from webfinger?
  # It does not work for every remote user!
  def public_feed_url
    "http://#{ webfinger_url }/api/user/#{ name }/public.atom"                       
  end

  # Return the slug in the webfinger_id
  def webfinger_slug
    splitted_webfinger_id.first
  end

  # Return the origin url in the webfinger_id
  def webfinger_url
    splitted_webfinger_id.last
  end

  protected

  def splitted_webfinger_id
    @splitted_webfinger_id ||=
      webfinger_id.split('@')
  end

  def fill_information
    self.name = webfinger_id
  end
end
