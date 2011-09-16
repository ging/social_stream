class Agenda < ActiveRecord::Base
  include SocialStream::Models::Object

  belongs_to :event
  has_many :sessions, :dependent => :destroy

  validates_presence_of :event_id

    # Fullcalendar slot values
  SLOT_VALUES=[5,15,30]

=begin
  def to_fullcalendar_json
    sessions.map(&:to_fullcalendar_json).join(", ")

    "[#{sessions.map(&:to_fullcalendar_json).join(", ")}]"
  end
=end


  def start_date
    event.start_at
  end

  def end_date
    event.end_at
  end

  def getSessions(id,time_start,time_end)
    @sessions = sessions.where( "start_at >= '#{time_start.to_formatted_s(:db)}' AND
                             end_at  <= '#{time_end.to_formatted_s(:db)}' ")
  end

  def contents_for_day(i)

      @sessions = sessions.where(
                "start_at >= :day_start AND start_at < :day_end", {:day_start => start_date.to_date + (i-1).day,
                :day_end => start_date.to_date + i.day})


  end

  def self.next_time_slot_for_drop_down
    if Time.zone.now.min > 40
      Time.zone.parse("#{Time.zone.now.hour + 1}:00")
    else
      Time.zone.parse("#{Time.zone.now.hour}:#{(Time.zone.now.min.to_f/SLOT_VALUES[1]).ceil*SLOT_VALUES[1]}")
    end
  end

end




