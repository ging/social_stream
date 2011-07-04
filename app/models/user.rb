require 'devise/orm/active_record'

class User < ActiveRecord::Base
  include SocialStream::Models::Subject

  has_many :authentications
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
  
  def recent_groups
    contact_subjects(:type => :group, :direction => :sent) do |q|
      q.select("contacts.created_at").
        merge(Contact.recent)
    end
  end

  # Subjects this user can acts as
  def represented
    contact_subjects(:direction => :received) do |q|
      q.joins(:sent_ties => { :relation => :permissions }).merge(Permission.represent)
    end
  end
  
  protected
  
  # From devise
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

     def find_first(options)
      raise options.inspect
    end
  
  class << self
    %w( email slug name ).each do |a|
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
          find_by_slug(login)
        end
      else
        super
      end
    end

    def find_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
      if required_attributes == [:email]
        find_or_initialize_with_error_by_email(attributes[:email], error)
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

    def find_or_create_for_facebook_oauth(access_token,signed_in_resource=nil)
      data = access_token['extra']['user_hash']
      print data
      auth = Authentication.find_by_provider_and_uid(access_token["provider"],access_token["uid"])
      user = User.find_by_email(data["email"])
      
      if user == nil
        user = User.create!(:name => data["name"], :email => data["email"], :password => Devise.friendly_token[0,20])
      end
      if auth == nil
        auth = Authentication.create!(:user_id => user.id, :uid =>access_token["uid"], :provider => access_token["provider"])
      end
      user
    end
    
    def find_or_create_for_linkedin_oauth(access_token,signed_in_resource=nil)
      auth = Authentication.find_by_uid_and_provider(access_token["uid"],access_token["provider"])
      if auth==nil
        user = User.create!(:name => access_token["user_info"]["name"], :email => 'demo@socialstream.com', :password => Devise.friendly_token[0,20])
        auth = Authentication.create!(:user_id => user.id, :uid =>access_token["uid"], :provider => access_token["provider"])
        user
      else
        user = User.find_by_id(auth.user_id)
        user
      end
    end
    
  end
end
