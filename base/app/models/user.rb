require 'devise/orm/active_record'

# Every social network must have users, and a social network builder couldn't be the exception.
#
# Social Stream uses the awesome gem {Devise https://github.com/plataformatec/devise}
# for managing authentication
#
# Almost all the logic of the interaction between {User} and the rest of classes in Social Stream
# is done through {Actor}. The glue between {User} and {Actor} is in {SocialStream::Models::Subject}
#
class User < ActiveRecord::Base
  include SocialStream::Models::Subject

  devise *SocialStream.devise_modules

  has_many :authentications, :dependent => :destroy

  has_many :user_authored_objects,
           :class_name => "ActivityObject",
           :foreign_key => :user_author_id

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :language, :remember_me, :profile_attributes

  validates_presence_of :email

  validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true

  validate :email_must_be_uniq
  
  with_options :if => :password_required? do |v|
    v.validates_presence_of     :password
    v.validates_confirmation_of :password
    v.validates_length_of       :password, :within => Devise.password_length, :allow_blank => true
  end
  
  def recent_groups size = 5
    contact_subjects(:type => :group, :direction => :sent) { |q|
      q.select("contacts.created_at").
        merge(Contact.recent).
        limit(size)
    }
  end

  # Subjects this user can acts as
  def represented
    candidates = contact_actors(:direction => :sent).map(&:id)

    contact_subjects(:direction => :received) do |q|
      q.joins(:sent_ties => { :relation => :permissions }).
        merge(Permission.represent).
        where(:id => candidates)
    end
  end
  
  protected
  
  # From devise
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  private

  def email_must_be_uniq
    user = User.find_by_email(email)
    if user.present? && user.id =! self.id
      errors.add(:email, "is already taken")
    end
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

    def find_or_create_for_facebook_oauth(hash, signed_in_resource = nil)
      puts hash.inspect
      auth = Authentication.find_by_provider_and_uid(hash["provider"], hash["uid"])
      user = User.find_by_email(hash["info"]["email"])

      if user.nil?
        user = User.create!(:name => hash["info"]["name"], :email => hash["info"]["email"], :password => Devise.friendly_token[0,20])
      end

      if auth.nil?
        auth = Authentication.create!(:user_id => user.id, :uid =>hash["uid"], :provider => hash["provider"])
      end

      user
    end
    
    def find_or_create_for_linkedin_oauth(hash,signed_in_resource=nil)
      auth = Authentication.find_by_uid_and_provider(hash["uid"],hash["provider"])
      if auth==nil
        user = User.create!(:name => hash["info"]["name"], :email => 'demo@socialstream.com', :password => Devise.friendly_token[0,20])
        auth = Authentication.create!(:user_id => user.id, :uid =>hash["uid"], :provider => hash["provider"])
        user
      else
        user = User.find_by_id(auth.user_id)
        user
      end
    end
    
  end
end
