class MailboxController < ApplicationController
  
  def index
    @mailbox = current_subject.mailbox 
  end
  
  def new
  end
  
  def create
  end
  
  def show
    if params[:id].blank? or !["inbox","sentbox","trash"].include?params[:id]
      redirect_to :action => :index
      return
    end
    @mailbox = current_subject.mailbox
    
    session[:mailbox_id]=params[:id]
    
    if params[:id].eql?"inbox"
      @conversations = @mailbox.inbox.paginate(:per_page => 8, :page => params[:page])      
    elsif params[:id].eql?"sentbox"
      @conversations = @mailbox.sentbox.paginate(:per_page => 8, :page => params[:page])      
    else
      @conversations = @mailbox.trash.paginate(:per_page => 8, :page => params[:page])      
    end
  end
  
end
