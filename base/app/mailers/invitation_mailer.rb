class InvitationMailer < ActionMailer::Base
  
  default :from => Mailboxer.default_from
  
  def send_invitation(receiver, sender, message)
    @sender= sender
    @message= message  
    mail(:to => receiver, :subject => "SocialStream Invitation")
  end

end