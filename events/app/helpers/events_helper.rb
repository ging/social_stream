module EventsHelper
  def event_class(day)
    begin_date = Time.now.beginning_of_week.to_date
    end_date   = begin_date + 28

    busy_dates =
      profile_or_current_subject.
        events.
        ocurrences(begin_date, end_date)

    [].tap { |css|
      css <<
        if day < Date.today
          "past"
        elsif day == Date.today
          "today"
        elsif day.month != Date.today.month
          "next_month"
        end


      css << "busy" if busy_dates.include?(day)

    }.join(" ")
  end
end
