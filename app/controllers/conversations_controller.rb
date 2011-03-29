class ConversationsController < ApplicationController

	before_filter :get_mailbox, :get_box, :get_actor
	def index
		if @box.eql?"inbox"
			@conversations = @mailbox.inbox.paginate(:per_page => 9, :page => params[:page])
		elsif @box.eql?"sentbox"
			@conversations = @mailbox.sentbox.paginate(:per_page => 9, :page => params[:page])
		else
			@conversations = @mailbox.trash.paginate(:per_page => 9, :page => params[:page])
		end
	end

	def show
		@conversation = Conversation.find_by_id(params[:id])
		if @conversation.nil? or !@conversation.is_participant?(@actor)
			redirect_to conversations_path(:box => @box)
			return
		end
		if @box.eql? 'trash'
		@receipts = @conversation.receipts(@actor).trash
		else
		@receipts = @conversation.receipts(@actor).not_trash
		end
		render :action => :show
		@receipts.mark_as_read
	end

	def new

	end

	def edit

	end

	def create

	end

	def update
		@conversation = Conversation.find_by_id(params[:id])
		if @conversation.nil? or !@conversation.is_participant?(@actor)
			redirect_to conversations_path(:box => @box)
		return
		end

		if params[:untrash].present?
		@conversation.untrash(@actor)
		end

		if params[:reply_all].present?
			if params[:body].present?
				last_receipt = @conversation.receipts(@actor).last
				@actor.reply_to_all(last_receipt, params[:body])
			end
		end

		if @box.eql? 'trash'
		@receipts = @conversation.receipts(@actor).trash
		else
		@receipts = @conversation.receipts(@actor).not_trash
		end
		render :action => :show
		@receipts.mark_as_read

	end

	def destroy
		@conversation = Conversation.find_by_id(params[:id])
		if @conversation.nil? or !@conversation.is_participant?(@actor)
			redirect_to conversations_path(:box => @box)
		return
		end

		@conversation.move_to_trash(@actor)

		if params[:location].present?
			case params[:location]
			when 'conversation'
				redirect_to conversations_path(:box => :trash)
				return
			else
			redirect_to conversations_path(:box => @box,:page => params[:page])
			return
			end
		end
		redirect_to conversations_path(:box => @box,:page => params[:page])
	end

	private

	def get_mailbox
		@mailbox = current_subject.mailbox
	end
	
	def get_actor
		@actor = Actor.normalize(current_subject)
	end

	def get_box
		if params[:box].blank? or !["inbox","sentbox","trash"].include?params[:box]
			@box = "inbox"
		return
		end
		@box = params[:box]
	end

end
