class NotificationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :get_mailbox, :get_actor
  before_filter :check_current_subject_is_owner, :only => [:show, :update, :destroy]
  
  def index
      @notifications = @mailbox.notifications.paginate(:per_page => 10, :page => params[:page])
  end

  def show
    render :action => :show
    @actor.read @notification
    
  end

  def new

  end

  def edit

  end

  def create

  end

  def update
    if params[:read].present?
      @actor.read @notification   
    end
    redirect_to notifications_path(:page => params[:page])
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path
  end

  private

  def get_mailbox
    @mailbox = current_subject.mailbox
  end

  def get_actor
    @actor = Actor.normalize(current_subject)
  end


  def check_current_subject_is_owner
    @notification = Notification.find_by_id(params[:id])

    if @notification.nil? #TODO or !@notification.is_receiver?(@actor)
      redirect_to notifications_path
    return
    end
  end

end
