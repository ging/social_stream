class Address < ActiveRecord::Base
  attr_accessible :streetAddress, :locality, :region, :postalCode, :country
  after_validation :set_formatted

  has_many :geotags, :autosave => true
  has_many :places, :through => :geotags, :autosave => true

  validates :streetAddress, :presence => true
  validates :locality, :presence => true
  #validates :region, :presence => true
  #validates :postalCode, :presence => true
  validates :country, :presence => true
  #validates_uniqueness_of :streetAddress, :scope => [:locality, :country]


  private
  
    def set_formatted

      self.formatted =	self.streetAddress + " " + 
			self.postalCode + " " + self.locality

      if !self.region.eql?("")
        self.formatted += " (" + self.region + ")"
      end

      self.formatted += " " + self.country
    end

end
