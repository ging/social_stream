class InvitationMailer < ActionMailer::Base
  
  def send_invitation(receiver, sender, message)
    @sender= sender
    @message= message  
    mail(:to => receiver, :subject => "SocialStream Invitation")
  end

end