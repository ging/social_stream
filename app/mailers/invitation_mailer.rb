class InvitationMailer < ActionMailer::Base
  
  def send_invitation(email, message)
    @message= message
    mail(:to => email, :subject => "SocialStream Invitation")  
  end

end