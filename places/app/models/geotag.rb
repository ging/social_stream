class Geotag < ActiveRecord::Base

	belongs_to :activity_object, :autosave => true
	belongs_to :address, :autosave => true

  def address!
    address || build_address
  end
end