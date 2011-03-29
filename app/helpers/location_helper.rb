module LocationHelper
	def location(*stack)
		location_body = t('location.base')
		stack.collect {|level|
			location_body << t('location.separator') + level
		}

		location_div = capture do
			render :partial => "location/location", :locals=>{:location_body => location_body}
		end
	end

end