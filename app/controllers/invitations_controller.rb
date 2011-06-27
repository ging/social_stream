class InvitationsController < ApplicationController
  
  def new 
    
  end
  
  def create
    puts "You have introduced the following e-mail addresses: "
    puts params[:mails]
    puts "And you have added the following message: "
    puts params[:message]
    redirect_to new_invitation_path
  end
end