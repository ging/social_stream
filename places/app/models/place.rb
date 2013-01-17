class Place < ActiveRecord::Base
  include SocialStream::Models::Object
  # Si hacemos accesible solo algunos atributos, poned:
  #attr_accessible :address_attributes, :title, :latitude, :longitude, :url, :phone_number, :author_id, :owner_id, :user_author_id, :relation_ids

  belongs_to :address, :autosave => true
  accepts_nested_attributes_for :address
		#, :reject_if => :all_blank

  before_save :format_website

  geocoded_by :full_address   # can also be an IP address
  before_validation :geocode  # auto-fetch coordinates

  acts_as_gmappable :process_geocoding => false

  validates :title, :presence => true, :length => { :maximum => 50 }
  validates :latitude, :presence => true
  validates :longitude, :presence => true


  # Solution to the problem: If place already exists, get the associated id.
  # Other solution to consider: Find the existing place in the controller or not use the nested_attributes

  def autosave_associated_records_for_address
    if new_address = Address.find_by_streetAddress_and_locality(address.streetAddress, address.locality) then
      self.address = new_address
    else
      self.address.save!
      self.address_id = address.id
    end
    self.valid?
  end

  protected
  def format_website
    if self.url.present? && !(self.url.start_with?("http://") || self.url.start_with?("https://"))
      self.url = "http://" + self.url
    end
  end

  def full_address
    self.address.formatted
  end


end