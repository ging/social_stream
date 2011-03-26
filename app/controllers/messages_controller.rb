class MessagesController < ApplicationController

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

	# GET /messages/1
	# GET /messages/1.xml
	def show
		@conversation = Conversation.find_by_id(params[:id])
		if @conversation.nil? or !@conversation.is_participant?(@actor)
			redirect_to messages_path(:box => @box)
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

	# GET /messages/new
	# GET /messages/new.xml
	def new
		if params[:receiver].present?
			@recipient = Actor.find_by_slug(params[:receiver])
			@recipient = nil if Actor.normalize(@recipient)==Actor.normalize(current_subject)
		end
	end

	# GET /messages/1/edit
	def edit

	end

	# POST /messages
	# POST /messages.xml
	def create
		@conversation = Conversation.new
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
			redirect_to message_path(@conversation, :box => :sentbox)
		else
			render :action => :new
		end
	end

	# PUT /messages/1
	# PUT /messages/1.xml
	def update
		@conversation = Conversation.find_by_id(params[:id])
		if @conversation.nil? or !@conversation.is_participant?(@actor)
			redirect_to messages_path(:box => @box)
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

	# DELETE /messages/1
	# DELETE /messages/1.xml
	def destroy
		@conversation = Conversation.find_by_id(params[:id])
		if @conversation.nil? or !@conversation.is_participant?(@actor)
			redirect_to messages_path(:box => @box)
		return
		end

		@conversation.move_to_trash(@actor)

		if params[:location].present?
			case params[:location]
			when 'conversation'
				redirect_to messages_path(:box => :trash)
				return
			else
			redirect_to messages_path(:box => @box,:page => params[:page])
			return
			end
		end
		redirect_to messages_path(:box => @box,:page => params[:page])
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
