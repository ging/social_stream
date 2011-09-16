class AgendasController < InheritedResources::Base
  #protect_from_forgery

  def schedule

  end

  def index

  end

  def edit
    @event = Event.find_by_slug(params[:id])


  end

  def get_sessions()
    @event = Event.find_by_slug(params[:id])
    @agenda = Agenda.find_by_id(@event.agenda.id)
    @sessions = @agenda.getSessions(@event.id,Time.at(params['start'].to_i),Time.at(params['end'].to_i))

    sessions = []
    @sessions.each do |session|
      sessions << {:id => session.id,
                   :title => session.title,
                   :description => session.description || "Some cool description here...",
                   :start => "#{session.start_at.iso8601}",
                   :end => "#{session.end_at.iso8601}",
                   :allDay => false,
                   :recurring =>  false,
                   :editable => true
                  }
    end
    render :text => sessions.to_json
  end

  def show
    @event = Event.find_by_slug(params[:id])


  end

  def create

  end





end


