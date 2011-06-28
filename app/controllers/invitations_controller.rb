class InvitationsController < ApplicationController
  
  def new 
    
  end
  
  def create
    puts "You have introduced the following e-mail addresses: "
    puts params[:mails]
    
    puts "And you have added the following message: "
    puts params[:message]
    
    if params[:mails].present?
      InvitationMailer.send_invitation(params[:mails], params[:message]).deliver
      redirect_to (new_invitation_path, :notice => 'Your invitations have successfully been sent')
    else
      redirect_to (new_invitation_path, :notice => 'Your request was unprocessable')
    end
    
  end
end