module NotificationsHelper
  def decode_notification notification_text, activity
    return if activity.nil?
    notification_text = notification_text.gsub(/\%\{sender\}/, link_to(truncate_name(activity.sender.name), activity.sender.subject))
    notification_text = notification_text.gsub(/\%\{sender.name\}/,truncate_name(activity.sender.name))

    if activity.direct_object.present?
      object = activity.direct_object
      object = object.subject if object.is_a? Actor
      notification_text=notification_text.gsub(/\%\{object\}/,link_to(object.class.to_s.downcase,object))
      notification_text=notification_text.gsub(/\%\{object.name\}/,object.class.to_s.downcase)
    else
      notification_text=notification_text.gsub(/\%\{object\}/,"nilclass")
      notification_text=notification_text.gsub(/\%\{object.name\}/,"nilclass")
    end

    notification_text
  end
end
