class Link < ActiveRecord::Base
  include SocialStream::Models::Object

  validates_presence_of :url

  attr_accessor :loaded

  before_create :check_loaded

  define_index do
    indexes title
    indexes description
    indexes url

    has created_at
  end

  def check_loaded
    if !self.loaded.eql?"true" and self.title.nil? and self.description.nil? and self.image.nil?
      o = Linkser.parse self.url, {:max_images => 1}
      if o.is_a? Linkser::Objects::HTML
        self.title = o.title if o.title
        self.description = o.description if o.description
        self.url = o.last_url
        if o.ogp and o.ogp.image
          self.image = o.ogp.image
        elsif o.images and o.images.first
          self.image = o.images.first.url
        end
      end
    end
  end

end
