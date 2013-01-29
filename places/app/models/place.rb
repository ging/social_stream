class Place < ActiveRecord::Base
  include SocialStream::Models::Object
  # Si hacemos accesible solo algunos atributos, poned:
  #attr_accessible :address_attributes, :title, :latitude, :longitude, :url, :phone_number, :author_id, :owner_id, :user_author_id, :relation_ids

  before_save :format_website

  geocoded_by :full_address   # can also be an IP address
  before_validation :geocode  # auto-fetch coordinates

  acts_as_gmappable :process_geocoding => false

  validates :title, :presence => true, :length => { :maximum => 50 }
  validates :latitude, :presence => true
  validates :longitude, :presence => true

  # def photo_object
  #   object_properties.
  #     where('activity_object_properties.type' => 'ActivityObjectProperty::Photo').
  #     first
  # end

  # def photo
  #   @photo ||=
  #     photo_object.try(:document) ||
  #     build_photo
  # end

  def photos
    photo_objects = object_properties.
      where('activity_object_properties.type' => 'ActivityObjectProperty::Photo')

    objects = Array.new
    photo_objects.each do |a|
      objects << a.try(:document)
    end
    objects
  end

  def photo
    @photo ||= build_photo
  end

  protected
  def format_website
    if self.url.present? && !(self.url.start_with?("http://") || self.url.start_with?("https://"))
      self.url = "http://" + self.url
    end
  end

  def full_address
    [self.streetAddress, self.locality, self.postalCode, self.country].compact.join(', ')
  end

  def build_photo
    Document.new(:place_property_object_id => activity_object_id,
                 :owner_id => owner_id)
  end

end