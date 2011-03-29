module LocationHelper
	
	def location(*stack)
		location_div = '<div id="map_location" class="content_size">' + t('location.base')

		stack.collect {|level|
			location_div << t('location.separator') + level
		}
		location_div <<'</div>'
		return raw location_div
	end

end