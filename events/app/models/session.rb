class Session < ActiveRecord::Base
  include SocialStream::Models::Object
  acts_as_conference_manager_session

  belongs_to :agenda
  has_one :event, :through => :agenda

  validates_presence_of :agenda_id

  acts_as_conference_manager_session
  def to_fullcalendar_json
    "{title: '#{name}', start: new Date(#{initDate.year},#{initDate.month-1},#{initDate.day},#{initDate.hour},#{initDate.min}),end: new Date(#{endDate.year},#{endDate.month-1},#{endDate.day},#{endDate.hour},#{endDate.min}),allDay: false}"
  end

  def sanitize_for_fullcalendar(string)
    string.gsub("\r","").gsub("\n","<br />").gsub(/["]/, '\'')
  end





end
