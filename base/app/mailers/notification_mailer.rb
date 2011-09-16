#OVERRING WARNING
#We must override the NotificationMailer from Mailboxer to change the new_notification_email method
#refer to it for more info
#NOTE: There is just few lines different from original Mailboxer NotificationMailer. Please maintain it
#updated for correct behaviour
class NotificationMailer < ActionMailer::Base
  default :from => Mailboxer.default_from
  #Sends and email for indicating a new notification to a receiver.
  #It calls new_notification_email.
  def send_email(notification,receiver)
    new_notification_email(notification,receiver)
  end

  include ActionView::Helpers::SanitizeHelper
  #DIFFERENT FROM ORIGINAL----------------------
  include Mailboxer::NotificationDecoder
  #END OF DIFFERENCE----------------------------

  #Sends an email for indicating a new message for the receiver
  def new_notification_email(notification,receiver)
    @notification = notification
    @receiver = receiver
    #DIFFERENT FROM ORIGINAL----------------------
    subject = notification.subject.to_s
    subject = decode_basic_notification(subject,notification.notified_object)
    subject = subject.gsub(/\n/,'')
    #END OF DIFFERENCE----------------------------
    subject = strip_tags(subject) unless subject.html_safe?
    mail(:to => receiver.send(Mailboxer.email_method,notification), :subject => t('mailboxer.notification_mailer.subject', :subject => subject)) do |format|
      format.text {render __method__}
      format.html {render __method__}
    end
  end
end
