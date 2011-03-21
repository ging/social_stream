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
  	@conversation = MailboxerConversation.new
  	if params[:subject].blank?
  		@conversation.errors.add("subject", "can't be empty")
  	end
  	if params[:body].blank?
  		@conversation.errors.add("body", "can't be empty")  		
  	end
  	if params[:_recipients].nil? or params[:_recipients]==[]
  		@conversation.errors.add("recipients", "can't be empty")  		
  	end
  	if @conversation.errors.any? 
  		render :action => :new
  		return  		
  	end
  	@actor = current_subject
  	@recipients = Array.new
  	params[:_recipients].each do |recp_id|
  		recp = Actor.find_by_id(recp_id)
  		next if recp.nil?
  		@recipients << recp
  	end
  	
  	if (mail = @actor.send_message(@recipients, params[:body], params[:subject]))  	
	  	@conversation = mail.conversation  	
	  	redirect_to mailbox_conversation_path(@conversation)
  	else
  		render :action => :new
  	end
  	
  end
  
  def update    
    @actor = Actor.normalize(current_subject)
    @conversation = MailboxerConversation.find_by_id(params[:id])
    if @conversation.nil? or !@conversation.is_participant?(@actor)
      redirect_to mailbox_index_path
      return
    end 
    
    if params[:untrash].present?
    	@conversation.untrash(@actor)
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
  	@actor = Actor.normalize(current_subject)
    @conversation = MailboxerConversation.find_by_id(params[:id])
    if @conversation.nil? or !@conversation.is_participant?(@actor)
      redirect_to mailbox_index_path
      return
    end 
    
    @conversation.move_to_trash(@actor)
    
    if params[:location].present?
    	case params[:location]
    	when 'conversation'
    		redirect_to mailbox_path(:id => :trash)    		
    	else
    		redirect_to mailbox_path(:id => params[:location])
    	end   	
    	
  	return
    end
    redirect_to mailbox_index_path
  end
  
  private
  
  def get_mailbox    
    @mailbox = current_subject.mailbox
  end
end
