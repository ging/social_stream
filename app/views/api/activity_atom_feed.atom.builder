atom_feed({'xmlns:activity' => 'http://activitystrea.ms/spec/1.0/'}) do |feed|
	feed.title(@user.name + ' public stream') 
	feed.updated(@activities.first.updated_at)
	feed.author do
		feed.name(@user.name)
	end
	
	for activity in @activities
		feed.entry(activity) do |entry|
		    #Atom compliant for not ActivityStream readers
			entry.title('Activity')
			entry.summary(activity.direct_object.text)
			
			#ActivityStream compliant
			
			entry.author do |a|
				a.name(activity.sender_subject.name)
				a.tag!('activity:object-type','person')
			end
			
			entry.tag!('activity:verb',activity.activity_verb.name)
			
			entry.tag!('activity:object') do |act_ob|
				act_ob.title('Activity')
				act_ob.tag!('activity:object-type','status')
				act_ob.publised(activity.created_at)
			end
			
			entry.content(activity.direct_object.text,:type=>'text/html')
			
		end
	end
	
	feed.link :rel => 'self',     :href=>request.url
	feed.link :rel => 'next',     :href=>api_my_home_url+'?page='+(params[:page].to_i+1).to_s
	
	if params[:page].to_i != 1
	feed.link :rel => 'previous', :href=>api_my_home_url+'?page='+(params[:page].to_i-1).to_s
	end	
end