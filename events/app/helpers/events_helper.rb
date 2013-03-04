module EventsHelper
  def sidebar_month_class(date)
    case date.month <=> Date.today.month
    when -1
      "past"
    when 0
      "current"
    when 1
      "next"
    end
  end

  def event_timeline_thumb(event)
    if event.poster.new_record?
      image_tag("poster.png")
    else
      thumb_for(event.poster, '80x113#')
    end
  end
end
