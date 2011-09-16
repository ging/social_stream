xml.instruct!
	xml.user do
		xml.uid @user.id
		xml.name @user.name
		xml.slug @user.slug
		xml.email @user.email
		xml.userSince @user.created_at
		xml.birthday @user.profile.birthday
		xml.organization @user.profile.organization
		xml.city @user.profile.city
		xml.country @user.profile.country
		xml.website @user.profile.website
		xml.ties do
			@user.actors(:subject_type => 'user', :direction => :senders).each do |u|
				xml.contact do
					xml.uid u.id
					xml.slug u.slug
				end
			end
			
			@user.actors(:subject_type => 'group', :direction => :senders).each do |g|
				xml.group do
					xml.gid g.id
					xml.slug g.slug
				end
			end
		end
end
