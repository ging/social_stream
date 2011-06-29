class InvitationsController < ApplicationController
  
  def new 
    
  end
  
  def create
    logger.debug "You have introduced the following e-mail addresses: #{params[:mails]}"
    
    logger.debug "And you have added the following message: #{params[:message]}"
    
    if params[:mails].present?
      InvitationMailer.send_invitation(params[:mails], params[:message]).deliver
      redirect_to new_invitation_path, :notice => 'Your invitations have successfully been sent'
    else
      redirect_to new_invitation_path, :notice => 'Your request was unprocessable'
    end
    
  end
end
