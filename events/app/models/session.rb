class Session < ActiveRecord::Base
  include SocialStream::Models::Object
  acts_as_conference_manager_session

  belongs_to :agenda
  has_one :event, :through => :agenda

  validates_presence_of :agenda_id

  acts_as_conference_manager_session
  def to_fullcalendar_json
    "{title: '#{name}', start: new Date(#{start_at.year},#{start_at.month-1},#{start_at.day},#{start_at.hour},#{start_at.min}),end: new Date(#{end_at.year},#{end_at.month-1},#{end_at.day},#{end_at.hour},#{end_at.min}),allDay: false}"
  end

  def sanitize_for_fullcalendar(string)
    string.gsub("\r","").gsub("\n","<br />").gsub(/["]/, '\'')
  end





end
