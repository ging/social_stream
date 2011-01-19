require 'devise/orm/active_record'

class User < ActiveRecord::Base
  devise *SocialStream.devise_modules

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :profile_attributes
  
  validates_presence_of :email

  validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true
  # TODO: uniqueness of email, which is in actor
  
  with_options :if => :password_required? do |v|
    v.validates_presence_of     :password
    v.validates_confirmation_of :password
    v.validates_length_of       :password, :within => Devise.password_length, :allow_blank => true
  end
  
  def age
    return nil if profile.birthday.blank? 
    now = Time.now.utc.to_date
    now.year - profile.birthday.year - (profile.birthday.to_date.change(:year => now.year) > now ? 1 : 0)
  end

  def recent_groups
    subjects(:subject_type => :group, :direction => :receivers) do |q|
      q & Tie.recent
    end
  end

  # Subjects this user can acts as
  def represented
    subjects(:direction => :senders) do |q|
      q.joins(:sent_ties => { :relation => :permissions }) & Permission.represent
    end
  end
  
  protected
  
  # From devise
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
  
  class << self
    %w( email permalink name ).each do |a|
      eval <<-EOS
    def find_by_#{ a }(#{ a })             # def find_by_email(email)
      find :first,                         #   find(:first,
           :include => :actor,             #         :include => :actor,
           :conditions =>                  #         :conditions =>
             { 'actors.#{ a }' => #{ a } } #           { 'actors.email' => email }
    end                                    # end
      EOS
    end
    
    # Overwrite devise default find method to support login with email,
    # presence ID and login
    def find_for_authentication(conditions)
      if ( login = conditions[:email] ).present?
        if login =~ /@/
          find_by_email(login)
        else
          find_by_permalink(login)
        end
      else
        super
      end
    end
    
    def find_or_initialize_with_error_by(attribute, value, error=:invalid)
      if attribute == :email
        find_or_initialize_with_error_by_email(value, error)
      else
        super
      end
    end
    
    # Overwrite devise default method to support finding with actor.email
    def find_or_initialize_with_error_by_email(value, error)
      if value.present?
        record = find_by_email(value)
      end
      
      unless record
        record = new
        
        if value.present?
          record.email = value
        else
          error = :blank
        end
        
        record.errors.add(:email, error)
      end
      
      record
    end
  end
end
