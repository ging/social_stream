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

end