atom_feed('xmlns:activity' => 'http://activitystrea.ms/spec/1.0/') do |feed|
  feed.link :rel => 'next', :href => url_for(:only_path => false, :page => params[:page].to_i + 1, :format => :atom)
  if params[:page].to_i > 1
    feed.link :rel => 'previous', :href => url_for(:only_path => false, :page => params[:page].to_i - 1, :format => :atom)
  end 

  #FIXME find a way to decouple the view from here

  if defined? SocialStream::Ostatus
    feed.link :rel => 'hub', :href => SocialStream::Ostatus.hub
  end

  feed.title(profile_subject.name + ' stream') 
  feed.updated(@activities.first.present? ? @activities.first.updated_at : Time.now)

  feed.author do
    feed.name(profile_subject.name)
  end

  @activities.each do |activity|
    feed.entry(activity) do |entry|
      entry.title(activity.title(self))
      entry.summary(activity.direct_object.try(:description))

      entry.author do |a|
        a.name(activity.sender.name)
        a.tag!('activity:object-type', 'person')
      end

      entry.tag!('activity:verb', activity.verb)

      entry.tag!('activity:object') do |act_ob|
        act_ob.title('Activity')
        act_ob.tag!('activity:object-type','status')
        act_ob.publised(activity.created_at)
      end

      entry.content(render(activity.activity_objects), :type => 'text/html')
    end
  end
end
