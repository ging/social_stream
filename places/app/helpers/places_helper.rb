module PlacesHelper

  def place_details_tab_class(place, tab)
    editing = place && place.errors.present?

    case tab
      when :edit
        editing ? 'active' : ''
      when :info
        editing ? '' : 'active'
      else
        ''
    end
  end

  # def place_timeline_thumb(place)
  #   if place.photo.new_record?
  #     # image_tag("photo.png")
  #   else
  #     thumb_for(place.photo, '80x113#')
  #   end
  # end

  # def place_timeline_thumb(place)
  #   unless place.photos.empty?
  #     thumb_for(place.photos.first, '80x113#')
  #     place.photos.each do |p|
  #       thumb_for(p, '80x113#')
  #     end
  #   end
  # end
end