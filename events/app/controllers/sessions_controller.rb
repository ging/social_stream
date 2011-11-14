class SessionsController < InheritedResources::Base

  before_filter :authenticate_user!

  def new
    @event= Event.find_by_id(params[:id])
    @session= Session.new

  end


  def edit
    @event= Event.find_by_id(params[:id_event])
    @session= Session.find_by_id(params[:id])

  end

  def update
    @event = Event.find_by_id(params[:id_event])
    params[:session][:agenda_id]=@event.agenda.id
    @session = Session.find_by_id(params[:id])
    @session.update_attributes(params[:session])
#    @session = Session.new (params[:session])
#    @session.save
    if @event.initDate.nil?
      @event.initDate = @session.initDate
      @event.endDate =   @session.endDate
      @event.save
    else
      if @event.initDate > @session.initDate
        @event.initDate = @session.initDate
      end
      if @event.endDate <  @session.endDate
        @event.endDate =  @session.endDate
      end
      @event.save
    end
    redirect_to "/agendas/"+@event.slug
  end

  def create
    @event = Event.find_by_id(params[:event_id])
    params[:session][:agenda_id]=@event.agenda.id
    @session = Session.new (params[:session])

    # default configuration for VC server
    @event.vc_mode = Event::VC_MODE.index(:in_person)
    @session.cm_streaming = @event.streaming_by_default # this param is to set streamming url for vc-event
    @session.cm_recording = true   #this param is only true if recording is automatic

    #debugger

    begin
      @session.save
    rescue StandardError => e
      @session.errors[:base]<<(e.to_s)
    end

    if @event.initDate.nil?
      @event.initDate = @session.initDate
      @event.endDate =   @session.endDate
      @event.save
    else
      if @event.initDate > @session.initDate
        @event.initDate = @session.initDate
      end
      if @event.endDate <  @session.endDate
        @event.endDate =  @session.endDate
      end
      @event.save
    end
#    render :json => @session
    redirect_to "/agendas/"+@event.slug
  end

  def index
    @event = Event.find_by_slug(params[:event_id])
    respond_to do |format|
      format.html
    end
  end

  def move
    @session = Session.find_by_id(params[:id])
    if @session
      @session.initDate = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@session.initDate))
      @session.endDate = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@session.endDate))
      @session.save
    end

    if @event.initDate.nil?
      @event.initDate = @session.initDate
      @event.endDate =  @session.endDate
      @event.save
    else
      if @event.initDate > @session.initDate
        @event.initDate = @session.initDate
      end
      if @event.endDate < @session.endDate
        @event.endDate = @session.endDate
      end
      @event.save
    end

    render :json => @session
  end

  def resize
    @session = Session.find(params[:id])
    if @session
      @session.endDate = (params[:minute_delta].to_i).minutes.from_now((params[:day_delta].to_i).days.from_now(@session.endDate))
      @session.save
    end
  end


  def destroy
    @session = Session.find(params[:id])
    @event = @session.event
    initDate=@session.initDate
    endDate=@session.endDate
    @session.destroy

    if !@event.initDate.nil?
      if initDate < @event.initDate
        #changing the initDate of the event
        @event.initDate = @event.sessions.order("initDate ASC").map{|x| x.initDate}.first
      end
      if endDate > @event.endDate
        #changing the endDate of the event
        @event.endDate = @event.sessions.order("endDate DESC").map{|x| x.endDate}.first
      end
      @event.save
    end    
    redirect_to "/agendas/"+@event.slug
  end


  def show
    @event = Event.find_by_slug(params[:id])

  end


 
end
