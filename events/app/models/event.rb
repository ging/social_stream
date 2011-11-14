class Event < ActiveRecord::Base
  include SocialStream::Models::Subject
  #acts_as_conference_manager_event

  has_one :agenda, :dependent => :destroy
  has_many :sessions, :through => :agenda

  attr_accessor :_founder
  attr_accessor :_participants

  delegate :description, :description=, :to => :profile!

  after_create :create_founder
  after_create :create_participants
  after_create :create_agenda

  scope :live_events, lambda { 
  where("events.initDate <= ? AND events.endDate > ?", Time.zone.now, Time.zone.now)
  }

  VC_MODE = [:in_person, :telemeeting, :teleconference, :teleclass]
  RECORDING_TYPE = [:automatic, :manual, :none]

  #acts_as_conference_manager_event
  def profile!
    actor!.profile || actor!.build_profile
  end

  def followers
    contact_subjects(:subject_type => :user, :direction => :received)
  end

  # Creates the ties between the group and the founder
  def create_founder
    founder =
      Actor.find_by_slug(_founder) || raise("Cannot create event without founder")

    sent_contacts.create! :receiver => founder,
                          :relation_ids => Array(relation_customs.sort.first.id)
  end

  # Creates the ties between the group and the participants
  def create_participants
     return if @_participants.blank?

     @_participants.each do |participant|

       participant_actor = Actor.find(participant)

       sent_contacts.create! :receiver => participant_actor,
                             :relation_ids => Array(relation_customs.sort.first.id)
     end
  end

  def create_agenda
    agenda = Agenda.new
    agenda._contact_id = self._contact_id
    self.agenda = agenda
  end

  def days
    if has_date?
      (endDate.to_date - initDate.to_date).to_i + 1
    else
      return 0
    end
  end

  #method to know if this event is happening now
  def is_happening_now?
     #first we check if start date is past and end date is future
     if has_date? && initDate.past? && endDate.future?
       true
     else
       return false
     end
  end


  #method to know if this event has any session now
  def has_session_now?
     get_session_now
  end

  def get_session_now
    #first we check if start date is past and end date is future
     if is_happening_now?
       #now we check the sessions
       agenda.agenda_entries.each do |session|
         return entry if entry.initDate.past? && entry.end_time.future?
       end
     end
     return nil
  end

  #method to know if an event happens in the future
  def future?
    return has_date? && initDate.future?
  end


  #method to know if an event happens in the past
  def past?
    return has_date? && endDate.past?
  end


  def has_date?
    initDate
  end

  def isabel_bw
    256
  end

  def get_formatted_date
    has_date? ?
    I18n::localize(initDate, :format => "%A, %d %b %Y #{I18n::translate('date.at')} %H:%M. #{get_formatted_timezone}") :
    I18n::t('date.undefined')
  end

  def get_formatted_day
    has_date? ?
    I18n::localize(initDate, :format => "%A, %d %b %Y #{I18n::translate('date.at')} %H:%M. #{get_formatted_timezone}") :
    I18n::t('date.undefined')
  end

  def get_formatted_timezone
    has_date? ?
      "#{Time.zone.name} (#{initDate.zone}, GMT #{initDate.formatted_offset})" :
    I18n::t('date.undefined')
  end

  #method to get the starting hour of an event in the correct format
  def get_formatted_hour
    has_date? ? initDate.strftime("%H:%M") : I18n::t('date.undefined')
  end



end
