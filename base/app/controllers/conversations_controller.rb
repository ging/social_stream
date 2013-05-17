class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_mailbox, :get_box, :get_actor
  before_filter :check_current_subject_in_conversation, :only => [:show, :update, :destroy]

  def index
    if @box.eql? "inbox"
      @conversations = @mailbox.inbox.page(params[:page]).per(9)
    elsif @box.eql? "sentbox"
      @conversations = @mailbox.sentbox.page(params[:page]).per(9)
    else
      @conversations = @mailbox.trash.page(params[:page]).per(9)
    end

    respond_to do |format|
      format.html { render @conversations if request.xhr? }
    end
  end

  def show
    if @box.eql? 'trash'
      @receipts = @mailbox.receipts_for(@conversation).trash
    else
      @receipts = @mailbox.receipts_for(@conversation).not_trash
    end
    render :action => :show
    @receipts.mark_as_read
  end

  def update
    if params[:untrash].present?
    @conversation.untrash(@actor)
    end

    if params[:reply_all].present?
      last_receipt = @mailbox.receipts_for(@conversation).last
      @receipt = @actor.reply_to_all(last_receipt, params[:body])
    end

    if @box.eql? 'trash'
      @receipts = @mailbox.receipts_for(@conversation).trash
    else
      @receipts = @mailbox.receipts_for(@conversation).not_trash
    end
    redirect_to :action => :show
    @receipts.mark_as_read

  end

  def destroy

    @conversation.move_to_trash(@actor)

    respond_to do |format|
      format.html {
        if params[:location].present? and params[:location] == 'conversation'
          redirect_to conversations_path(:box => :trash)
	else
          redirect_to conversations_path(:box => @box,:page => params[:page])
	end
      }
      format.js {
        if params[:location].present? and params[:location] == 'conversation'
          render :js => "window.location = '#{conversations_path(:box => @box,:page => params[:page])}';"
	else
          render 'conversations/destroy'
	end
      }
    end
  end

  private

  def get_mailbox
    @mailbox = current_actor.mailbox
  end

  def get_actor
    @actor = Actor.normalize(current_subject)
  end

  def get_box
    if params[:box].blank? or !["inbox","sentbox","trash"].include?params[:box]
      params[:box] = 'inbox'
    end

    @box = params[:box]
  end

  def check_current_subject_in_conversation
    @conversation = Conversation.find_by_id(params[:id])

    if @conversation.nil? or !@conversation.is_participant?(@actor)
      redirect_to conversations_path(:box => @box)
    return
    end
  end

end
