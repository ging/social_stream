class Event < ActiveRecord::Base
  include SocialStream::Models::Object

  scheduler

  belongs_to :room

  validates_presence_of :title

  validate :room_belongs_to_receiver

  def to_json(options = {})
    if recurrence
      st = options[:start].try(:to_date)
      en = (options[:end] || end_at.end_of_month + 7.days).to_date

      recurrence.events(:starts => st, :until  => en).map do |d|

        start_diff = d - start_at.to_date
        end_diff   = d - end_at.to_date

        build_json start_at.advance(:days => start_diff),
                   end_at.advance(:days => end_diff)
      end
    else
      build_json 
    end
  end

  protected

  def build_json(start_time = start_at, end_time = end_at)
      {
        :id => id,
        :title => title,
        :start => start_time,
        :end => end_time,
        :allDay => all_day?,
        :roomId => room_id
      }

  end

  private

  def room_belongs_to_receiver
    return if room_id.blank?

    unless _contact.receiver.room_ids.include?(room_id)
      errors.add(:room_id, :invalid)
    end
  end
end
