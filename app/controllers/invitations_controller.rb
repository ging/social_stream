class InvitationsController < ApplicationController
  
  def new 
    
  end
  
  def create
    
    if params[:mails].present?
      receivers = params[:mails].split(",")
      receivers.each do |receiver|
        InvitationMailer.send_invitation(receiver, current_subject, params[:message]).deliver
      end
      redirect_to new_invitation_path, :flash => { :success => t('invitation.success')}
    else
      redirect_to new_invitation_path, :flash => { :error => t('invitation.error')}
    end
    
  end
end
