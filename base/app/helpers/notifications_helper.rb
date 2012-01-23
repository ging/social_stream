module NotificationsHelper

  # Set locale as per subject preference
  def locale_as(subject)
    if subject.respond_to? :language
      I18n.locale = subject.language || I18n.default_locale
    end
  end

end
