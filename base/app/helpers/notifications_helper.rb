module NotificationsHelper

  # An activity object title
  def title_of(act_obj)
    if act_obj.is_a? Comment
      'Re: ' + title_of(act_obj.parent_post)
    elsif act_obj.respond_to? :title and (not act_obj.title.nil?)
      act_obj.title.truncate(30, :separator => ' ')
    elsif act_obj.respond_to? :url and (not act_obj.url.nil?)
      act_obj.url.truncate(30, :separator => ' ')
    else I18n.t('notification.default')
    end
  end

  # An activity object description
  def description_of(act_obj)
    if act_obj.respond_to? :description and (not act_obj.description.nil?)
      sanitize(act_obj.description)
    else
      I18n.t('notification.watch_it')
    end
  end

  # Set locale as per subject preference
  def locale_as(subject)
    if subject.respond_to? :language
      I18n.locale = subject.language || I18n.default_locale
    end
  end

  # Add notification_id param to URL in order to mark notification read
  def notification_url_of(target, notification)
    return polymorphic_url(target, :notification_id => notification.id) unless notification.nil?
    polymorphic_url(target)
  end


end
