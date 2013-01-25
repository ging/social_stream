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

  def place_timeline_thumb(place)
    if place.poster.new_record?
      image_tag("poster.png")
    else
      thumb_for(place.poster, '80x113#')
    end
  end
end