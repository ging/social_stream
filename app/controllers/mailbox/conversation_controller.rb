class Mailbox::ConversationController < ApplicationController
  
  before_filter :get_mailbox
  
  
  def show
    @actor = Actor.normalize(current_subject)
    @conversation = MailboxerConversation.find_by_id(params[:id])
    if @conversation.nil? or !@conversation.is_participant?(@actor)
      redirect_to mailbox_index_path
      return
    end    
    @mails = @conversation.mails(@actor)
    #    messages = Array.new
    #    @mails.each do |mail|
    #      messages << mail.message
    #    end
    #    @messages = messages.uniq
  end
  
  def new
  end
  
  def edit
  end
  
  def create
  end
  
  def update    
    @actor = Actor.normalize(current_subject)
    @conversation = MailboxerConversation.find_by_id(params[:id])
    if @conversation.nil? or !@conversation.is_participant?(@actor)
      redirect_to mailbox_index_path
      return
    end 
    
    if params[:reply_all].present?
      if params[:body].present?
        last_mail = @conversation.mails(@actor).last
        @actor.reply_to_all(last_mail, params[:body])
      end
    end
    
    @mails = @conversation.mails(@actor)
    render :action => :show
  end
  
  def destroy
  end
  
  private
  
  def get_mailbox    
    @mailbox = current_subject.mailbox
  end
end
