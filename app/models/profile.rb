class Profile < ActiveRecord::Base
  belongs_to :actor
    
  accepts_nested_attributes_for :actor
  
  validates_presence_of :actor_id
  
  validates_format_of :mobile, :phone, :fax,
                      :allow_nil  => true,
                      :with       => /(^$)|(((\((\+?)\d+\))?|(\+\d+)?)[ ]*-?(\d+[ ]*\-?[ ]*\d*)+$)/,
                      :message    => "has a invalid format"
  
  validates_format_of :website,
                      :allow_nil  => true,
                      :with       => /(^$)|((https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$)/ ,
                      :message    => "has a invalid format"
  
  validate :validate_birthday
  
  def birthday=(value)    
    if value.blank?
      @birthday_formatted_invalid = false    
      super value
    else
      begin
        super Date.parse(value)
        @birthday_formatted_invalid = false
      rescue 
        @birthday_formatted_invalid = true
      end
    end
  end
  
  def age
    return nil if self.birthday.blank? 
    now = Time.now.utc.to_date
    now.year - self.birthday.year - (self.birthday.to_date.change(:year => now.year) > now ? 1 : 0)
  end
  
  # The subject of this profile
  def subject
    actor.try(:subject)
  end
  
  private

  def validate_birthday
    errors.add(:birthday, "is invalid. Please, use \"month/day/year\" format and make sure you choose a valid date" ) if (@birthday_formatted_invalid) || (birthday.present? && !birthday.blank? && birthday > Date.today)
  end

  
  
end
