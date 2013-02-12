module SocialStream
  module Places
    module Models
      module ActivityObject
        extend ActiveSupport::Concern

        included do
          has_one :geotag, :autosave => true
          has_one :address, :through => :geotag, :autosave => true

          delegate  :latitude, :latitude=, 
                    :longitude, :longitude=,
                    :altitude, :altitude=,
                    :heading, :heading=,
                    :tilt, :tilt=,
                    :to => :geotag!

          delegate  :formatted, :formatted=, 
                    :streetAddress, :streetAddress=,
                    :locality, :locality=,
                    :region, :region=,
                    :postalCode, :postalCode=,
                    :country, :country=,
                    :to => :address!
        end

        def geotag!
          geotag || build_geotag
        end

        def address!
          geotag!.address!
        end
        
      end
    end
  end
end
