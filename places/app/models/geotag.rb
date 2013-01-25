class Geotag < ActiveRecord::Base

	belongs_to :activity_object, :autosave => true
	belongs_to :address, :autosave => true

	before_validation :lookfor_address

  def address!
    address || build_address
  end

  private

  def lookfor_address
    if new_address = Address.find_by_streetAddress_and_locality(address.streetAddress, address.locality)
    	self.address = new_address
    end
  end

end