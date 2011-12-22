module EventsHelper
  def event_class(day)
    [].tap { |css|
      css <<
        if day < Date.today
          "past"
        elsif day == Date.today
          "today"
        elsif day.month != Date.today.month
          "next_month"
        end

      #TODO: event ocurrence
    }.join(" ")
  end
end
