class Mailbox::ConversationController < ApplicationController


  def show
    @actor = Actor.normalize(current_subject)
    @conversation = MailboxerConversation.find_by_id(params[:id])
    if @conversation.nil? #o no es participante
      redirect_to mailbox_index_path
      return
    end    
    @mails = @conversation.mails(@actor)
    messages = Array.new
    @mails.each do |mail|
      messages << mail.message
    end
    @messages = messages.uniq
  end

  def new
    @mailbox_conversation = Mailbox::Conversation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mailbox_conversation }
    end
  end

  def edit
    @mailbox_conversation = Mailbox::Conversation.find(params[:id])
  end

  def create
    @mailbox_conversation = Mailbox::Conversation.new(params[:mailbox_conversation])

    respond_to do |format|
      if @mailbox_conversation.save
        format.html { redirect_to(@mailbox_conversation, :notice => 'Conversation was successfully created.') }
        format.xml  { render :xml => @mailbox_conversation, :status => :created, :location => @mailbox_conversation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mailbox_conversation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @mailbox_conversation = Mailbox::Conversation.find(params[:id])

    respond_to do |format|
      if @mailbox_conversation.update_attributes(params[:mailbox_conversation])
        format.html { redirect_to(@mailbox_conversation, :notice => 'Conversation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mailbox_conversation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @mailbox_conversation = Mailbox::Conversation.find(params[:id])
    @mailbox_conversation.destroy

    respond_to do |format|
      format.html { redirect_to(mailbox_conversations_url) }
      format.xml  { head :ok }
    end
  end
end
