atom_feed('xmlns:activity' => 'http://activitystrea.ms/spec/1.0/') do |feed|
  feed.link :rel => 'next', :href => url_for(:only_path => false, :page => params[:page].to_i + 1, :format => :atom)
  if params[:page].to_i > 1
    feed.link :rel => 'previous', :href => url_for(:only_path => false, :page => params[:page].to_i - 1, :format => :atom)
  end 

  #FIXME find a way to decouple the view from here

  if defined? SocialStream::Ostatus
    feed.link :rel => 'hub', :href => SocialStream::Ostatus.hub
    feed.link rel: 'salmon', href: salmon_url(profile_subject.slug)
  end

  feed.title(t 'activity.stream.atom_title', subject: profile_subject.name) 
  feed.updated(@activities.first.present? ? @activities.first.updated_at : Time.now)

  feed.author do
    feed.name(profile_subject.name)
    feed.uri("acct:#{ profile_subject.slug }@#{ request.host_with_port }")
    feed.tag!('activity:object-type', profile_subject.as_object_type.to_s)
  end

  @activities.each do |activity|
    feed.entry(activity) do |entry|
      entry.title(activity.stream_title)
      entry.summary(activity.direct_object.try(:description))

      entry.author do |a|
        a.name(activity.sender.name)
        a.uri("acct:#{ activity.sender.slug }@#{ request.host_with_port }")
        a.tag!('activity:object-type', activity.sender.as_object_type.to_s)
      end

      #TODO Ostatus mentions:
      # entry.link rel: mentioned, href: "acct:#{ mentioned.slug }@#{ host_with_port }"

      entry.tag!('activity:verb', activity.verb)

      if (obj = activity.direct_object).present?
        entry.tag!('activity:object') do |act_obj|
          act_obj.title(obj.title)
          act_obj.tag!('activity:object-type', obj.as_object_type.to_s)
          act_obj.published(obj.created_at)
        end
      end
    end
  end
end
