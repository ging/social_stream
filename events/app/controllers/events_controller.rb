class EventsController < ApplicationController
  include SocialStream::Controllers::Objects

  before_filter :profile_subject!, :only => :index

  def index
    index! do |format|
      format.js {
        events_with_start_and_end
      }

      format.json {
        events_with_start_and_end

        render :json =>
          @events.
            map{ |e| e.to_json(:start => @start_time, :end => @end_time) }.flatten.to_json
      }
    end
  end

  def show
    show! do |format|
      format.html { redirect_to polymorphic_path([ @event.post_activity.receiver_subject, Event.new ], :at => @event.start_at.to_i) }
    end
  end

  private

  def events_with_start_and_end
    @start_time = Time.at(params[:start].to_i)
    @end_time   = Time.at(params[:end].to_i)

    subject = profile_or_current_subject

    @events = Event.followed_by(subject)

    if subject != current_subject
      @events = @events.shared_with(current_subject)
    end

    @events = @events.between(@start_time, @end_time)
  end
end
