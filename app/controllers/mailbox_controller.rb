class MailboxController < ApplicationController
  
  def index
    @mailbox = current_subject.mailbox
    @conversations = @mailbox.conversations.paginate(:per_page => 8, :page => params[:page])
  end

  def new
  end

  def create
  end

  def show
    @conversation = MailboxerConversation.find_by_id(params[:id])
    if @conversation.nil? #o no es participante
      redirect_to :action => :index
    end
    
    @mails = @conversation.mails(current_subject)
  end

end
