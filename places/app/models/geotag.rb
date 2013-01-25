class Geotag < ActiveRecord::Base

	belongs_to :activity_object, :autosave => true
	belongs_to :address, :autosave => true

  def address!
    address || build_address
  end

  def autosave_associated_records_for_address
    if new_address = Address.find_by_streetAddress_and_locality(address.streetAddress, address.locality) then
      self.address = new_address
    else
      self.address.save!
      self.address_id = address.id
    end
  end


end