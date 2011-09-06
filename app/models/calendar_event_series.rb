# == Schema Information
# Schema version: 20100330111833
#
# Table name: event_series
#
#  id         :integer(4)      not null, primary key
#  frequency  :integer(4)      default(1)
#  period     :string(255)     default("months")
#  starttime  :datetime
#  endtime    :datetime
#  all_day    :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class CalendarEventSeries < ActiveRecord::Base
  attr_accessor   :commit_button
  attr_accessible :id, :title, :description, :starttime, :endtime, :frequency, :period, :all_day, :object_type, :object_id
  
  validates_presence_of :frequency, :period, :starttime, :endtime
  validates_presence_of :title, :description
  
  has_many :calendar_events, :dependent => :destroy
  
  belongs_to :object, :polymorphic => true 
    
  named_scope :object_type, lambda { |type|
      type ?
        { :conditions => [ "object_type = ?", type.to_s.classify ] } :
        {}
  }

  def after_create
    #create_events_until
  end
  
  def self.find_or_create(starttime, endtime, room_id)
    calendar_series = self.find(:all, :conditions => [ "object_type = 'Room' AND object_id=?", room_id ] )
    logger.error "*** calendar_series.size = #{calendar_series.size}"
	  for iterador in calendar_series
      logger.error "*** iterador.id = #{iterador.id}"    	  
		if iterador.all_day
		  if iterador.repeat_until.nil?
		  	indice= ((endtime - iterador.starttime)/(iterador.frequency.send(iterador.r_period(iterador.period)) )).to_i
			  fecha_consulta= (indice*iterador.frequency).send(iterador.r_period(iterador.period)).from_now(iterador.starttime)
			  fecha_consulta_end= (indice*iterador.frequency).send(iterador.r_period(iterador.period)).from_now(iterador.endtime)

			  logger.error "#{fecha_consulta} #{fecha_consulta_end}"
			  eventos= CalendarEvent.find(:all, :conditions => ["starttime =? AND calendar_event_series_id=?",fecha_consulta,iterador.id])
			  logger.error "tamanio #{eventos.size}"
			  if eventos.size == 0
				  CalendarEvent.create(:title=>iterador.title,:description=>iterador.description,:starttime=>fecha_consulta,:endtime=>fecha_consulta_end,:all_day=>iterador.all_day,:object_type=>'Room',:object_id=>room_id, :calendar_event_series_id=>iterador.id)
			  end
	    else
		    if endtime <= iterador.repeat_until
			    indice= ((endtime - iterador.starttime)/(iterador.frequency.send(iterador.r_period(iterador.period)) )).to_i

			    fecha_consulta= (indice*iterador.frequency).send(iterador.r_period(iterador.period)).from_now(iterador.starttime)
			    fecha_consulta_end= (indice*iterador.frequency).send(iterador.r_period(iterador.period)).from_now(iterador.endtime)
			    logger.error fecha_consulta
			    eventos= CalendarEvent.find(:all, :conditions => ["starttime =? AND calendar_event_series_id=?",fecha_consulta,iterador.id])
			    if eventos.size == 0
				    CalendarEvent.create(:title=>iterador.title,:description=>iterador.description,:starttime=>fecha_consulta,:endtime=>fecha_consulta_end,:all_day=>iterador.all_day,:object_type=>'Room',:object_id=>room_id, :calendar_event_series_id=>iterador.id)
			    end
		    end	
              end  

		else
		  if iterador.repeat_until.nil? || endtime <= iterador.repeat_until
			indice= ((endtime - iterador.starttime)/(iterador.frequency.send(iterador.r_period(iterador.period)) )).to_i

			fecha_consulta= (indice*iterador.frequency).send(iterador.r_period(iterador.period)).from_now(iterador.starttime)
			fecha_consulta_end= (indice*iterador.frequency).send(iterador.r_period(iterador.period)).from_now(iterador.endtime)

			logger.error fecha_consulta
			eventos= CalendarEvent.find(:all, :conditions => ["starttime =? AND endtime=? AND calendar_event_series_id=?",fecha_consulta,fecha_consulta_end,iterador.id])
			if eventos.size == 0
				CalendarEvent.create(:title=>iterador.title,:description=>iterador.description,:starttime=>fecha_consulta,:endtime=>fecha_consulta_end,:all_day=>iterador.all_day,:object_type=>'Room',:object_id=>room_id, :calendar_event_series_id=>iterador.id)
			end
		  end	
		end
	end
  end
   
  def create_events_until

    st = starttime
    et = endtime
    p = r_period(period)
    nst, net = st, et
    while frequency.send(p).from_now(st) <= repeat_until
#    logger.error "*** title=#{title} description=#{description} all_day=#{all_day}"
#    logger.error "*** starttime=#{nst} endtime=#{net} object_id=#{object_id} object_type=#{object_type}"

    #while frequency.send(p).from_now(st) <= end_time
#      puts "#{nst}           :::::::::          #{net}" if nst and net
      self.calendar_events.create(:title => title, :description => description, :all_day => all_day, :starttime => nst, :endtime => net, :object_id => object_id, :object_type => 'Room')
      nst = st = frequency.send(p).from_now(st)
      net = et = frequency.send(p).from_now(et)
      
      if period.downcase == 'monthly' or period.downcase == 'yearly'
        begin 
          nst = DateTime.parse("#{starttime.hour}:#{starttime.min}:#{starttime.sec}, #{starttime.day}-#{st.month}-#{st.year}")  
          net = DateTime.parse("#{endtime.hour}:#{endtime.min}:#{endtime.sec}, #{endtime.day}-#{et.month}-#{et.year}")
        rescue
          nst = net = nil
        end
      end
    end
  end
  
  def r_period(period)
    case period
      when 'Daily'
      p = 'days'
      when "Weekly"
      p = 'weeks'
      when "Monthly"
      p = 'months'
      when "Yearly"
      p = 'years'
    end
    return p
  end
  
end
