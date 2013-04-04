class Link < ActiveRecord::Base
  include SocialStream::Models::Object

  validates_presence_of :url

  attr_accessor :loaded

  before_create :check_loaded

  define_index do
    activity_object_index

    indexes url
  end

  def fill linkser_object
    self.title = linkser_object.title if linkser_object.title
    self.description = linkser_object.description if linkser_object.description
    self.url = linkser_object.last_url
    r = linkser_object.resource
    if r and r.type and r.url      
      self.callback_url = r.url
    end
    self.width  = r.width  if r and r.width
    self.height = r.height if r and r.height
    if linkser_object.ogp and linkser_object.ogp.image
      self.image = linkser_object.ogp.image
    elsif linkser_object.images and linkser_object.images.first
      self.image = linkser_object.images.first.url
    end
  end

  def check_loaded
    return if loaded.present?
    begin
      o = Linkser.parse self.url, {:max_images => 1}

      if o.is_a? Linkser::Objects::HTML
        self.fill o
      end
    rescue
    end
  end

  def improved_callback_url
    if callback_url =~ /youtube\.com\/v\/.+/
      callback_url + '&autoplay=1'
    else
      callback_url
    end
  end
end
