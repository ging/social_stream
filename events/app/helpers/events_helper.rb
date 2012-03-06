module EventsHelper
  def event_timeline_thumb(event)
    if event.poster.new_record?
      ""
    else
      thumb_for(event.poster, 80)
    end
  end
end
