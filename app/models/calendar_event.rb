# == Schema Information
# Schema version: 20100330111833
#
# Table name: events
#
#  id              :integer(4)      not null, primary key
#  title           :string(255)
#  starttime       :datetime
#  endtime         :datetime
#  all_day         :boolean(1)
#  created_at      :datetime
#  updated_at      :datetime
#  description     :text
#  event_series_id :integer(4)
#

class CalendarEvent < ActiveRecord::Base
  attr_accessor :period, :frequency, :commit_button
  
  validates_presence_of :title, :description
  
  belongs_to :calendar_event_series
  
  belongs_to :object, :polymorphic => true 
  
  named_scope :object_type, lambda { |type|
      type ?
        { :conditions => [ "object_type = ?", type.to_s.classify ] } :
        {}
  }
    
  REPEATS = [
              ["No repetir",   "Does not repeat"],
#              ["Diariamente",  "Daily"          ],
              ["Semanalmente", "Weekly"         ]
#              ["Mensualmente", "Monthly"        ],
#              ["Anualmente",   "Yearly"         ]
  ]
  
  def validate
    if (starttime >= endtime) and !all_day
      errors.add_to_base("Inicio debe ser menor que Fin")
    end
  end

  def update_calendar_events(events, event)
    events.each do |e|
      begin 
        st, et = e.starttime, e.endtime
        e.attributes = event
        if calendar_event_series.period.downcase == 'monthly' or calendar_event_series.period.downcase == 'yearly'
          nst = DateTime.parse("#{e.starttime.hour}:#{e.starttime.min}:#{e.starttime.sec}, #{e.starttime.day}-#{st.month}-#{st.year}")  
          net = DateTime.parse("#{e.endtime.hour}:#{e.endtime.min}:#{e.endtime.sec}, #{e.endtime.day}-#{et.month}-#{et.year}")
        else
          nst = DateTime.parse("#{e.starttime.hour}:#{e.starttime.min}:#{e.starttime.sec}, #{st.day}-#{st.month}-#{st.year}")  
          net = DateTime.parse("#{e.endtime.hour}:#{e.endtime.min}:#{e.endtime.sec}, #{et.day}-#{et.month}-#{et.year}")
        end
        #puts "#{nst}           :::::::::          #{net}"
      rescue
        nst = net = nil
      end
      if nst and net
        #          e.attributes = event
        e.starttime, e.endtime = nst, net
        e.save
      end
    end
    
    calendar_event_series.attributes = event
    calendar_event_series.save
  end
  
  #method to know if an event happens in the future
  def future?
    return has_date? && starttime.future?    
  end
  
  
  #method to know if an event happens in the past
  def past?
  return has_date? && endtime.past?
  end
  
  
  def has_date?
    starttime
  end

  #method to get the starting date of an event in the correct format
  def get_formatted_date
    has_date? ?
      I18n::localize(starttime, :format => "%A, %d %b %Y #{I18n::translate('date.at')} %H:%M. #{get_formatted_timezone}") :
      I18n::t('date.undefined')       
  end
  
  def get_formatted_timezone
    has_date? ?
      "#{I18n::t('timezone.one')}: #{Time.zone.name} (#{starttime.zone}, GMT #{starttime.formatted_offset})" :
      I18n::t('date.undefined')
  end
  
  #method to get the starting hour of an event in the correct format
  def get_formatted_hour
    has_date? ? starttime.strftime("%H:%M") : I18n::t('date.undefined')  
  end
  
  def get_formatted_timezone_lite
      has_date? ?
        "GMT #{starttime.formatted_offset}" :
        I18n::t('date.undefined')
  end

  def to_s
    s = I18n.localize(starttime, :format => '%A %d de %B de %Y')
    if (starttime.strftime('%Y-%m-%d') == endtime.strftime('%Y-%m-%d'))
      s += " de " + starttime.strftime("%H:%M") + " hasta " + endtime.strftime("%H:%M") + " " + get_formatted_timezone_lite
    end
    #starttime.strftime '%m/%d/%Y' + ' hasta ' + endtime.strftime '%m/%d/%Y'  
  end  

  def to_string(timezone)
    s = I18n.localize(starttime, :format => '%A %d de %B de %Y')
    if (starttime.strftime('%Y-%m-%d') == endtime.strftime('%Y-%m-%d'))
logger.error "timezone= #{timezone}"
      if (!timezone.nil? && timezone != "")
        s += " de " + starttime.in_time_zone(timezone).strftime("%H:%M") + " hasta " + endtime.in_time_zone(timezone).strftime("%H:%M") + " GMT #{starttime.in_time_zone(timezone).formatted_offset}"
      end 
      s += " (" + starttime.utc.strftime("%H:%M") + " hasta " + endtime.utc.strftime("%H:%M") + " GMT)"
    end
    #starttime.strftime '%m/%d/%Y' + ' hasta ' + endtime.strftime '%m/%d/%Y'  
  end

  def in(nce)
    return (starttime <= nce.starttime && endtime > nce.starttime) || (starttime < nce.endtime && endtime >= nce.endtime)
  end

  def self.find_room(reservation, room_id)
    logger.error "reservation=#{reservation.id} room=#{room_id}"
    room_object=Room.find room_id    
    calendar_events_roster = room_object.calendar_events
    logger.error "*** calendar_series.size = #{calendar_events_roster.size}"
    for iterador in calendar_events_roster
      logger.error "*** iterador.id = #{iterador.id} all_day=#{iterador.all_day}"  
      if iterador.all_day		  	
        logger.error "#{iterador.starttime} #{iterador.endtime}"
        eventos = CalendarEvent.find(:all, :conditions => ["object_type = 'Room' AND object_id=? AND ((starttime <= ? AND endtime> ?) OR (starttime< ? AND endtime>= ? ))", room_id, iterador.starttime, iterador.starttime, iterador.endtime, iterador.endtime])
        logger.error "tamanio #{eventos.size}"
        if eventos.size != 0
          return false
        end	    	 
      else
        logger.error "#{iterador.starttime} #{iterador.endtime}"
        eventos = CalendarEvent.find(:all, :conditions => ["object_type = 'Room' AND object_id=? AND ((starttime <= ? AND endtime> ?) OR (starttime< ? AND endtime>= ? ))", room_id, iterador.starttime, iterador.starttime, iterador.endtime, iterador.endtime])
        logger.error "tamanio #{eventos.size}"
        if eventos.size != 0
          return false
        end
      end
    end
    return true
  end 

  def self.find_room_reserved(reservation, room_id)
    logger.error "reserved reservation=#{reservation.id} room=#{room_id}"
    reservations_approved = Reservation.find(:all, :conditions => ["room_id=? AND state=?", room_id, Reservation::STATE_APPROVED])
    for reservation_approved in reservations_approved
      calendar_events_roster = reservation_approved.calendar_events
      logger.error "*** reserved calendar_series.size = #{calendar_events_roster.size}"
      for iterador in calendar_events_roster
        logger.error "*** reserved iterador.id = #{iterador.id} all_day=#{iterador.all_day}"  
        if iterador.all_day		  	
          logger.error "reserved {iterador.starttime} #{iterador.endtime}"
          eventos = CalendarEvent.find(:all, :conditions => ["object_type = 'Room' AND object_id=? AND ((starttime <= ? AND endtime> ?) OR (starttime< ? AND endtime>= ? ))", room_id, iterador.starttime, iterador.starttime, iterador.endtime, iterador.endtime])
          logger.error "reserved tamanio #{eventos.size}"
          if eventos.size != 0
            return false
          end	    	 
        else
          logger.error "reserved #{iterador.starttime} #{iterador.endtime}"
          eventos = CalendarEvent.find(:all, :conditions => ["object_type = 'Room' AND object_id=? AND ((starttime <= ? AND endtime> ?) OR (starttime< ? AND endtime>= ? ))", room_id, iterador.starttime, iterador.starttime, iterador.endtime, iterador.endtime])
          logger.error "reserved tamanio #{eventos.size}"
          if eventos.size != 0
            return false
          end
        end
      end
    end
    return true
  end

end
