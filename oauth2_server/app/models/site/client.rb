class Site::Client < Site
  validates_presence_of :url, :callback_url, :secret

  has_many :oauth2_tokens,
           foreign_key: 'site_id',
           dependent: :destroy

  has_many :authorization_codes,
           foreign_key: 'site_id',
           class_name: 'Oauth2Token::AuthorizationCode'

  has_many :access_tokens,
           foreign_key: 'site_id',
           class_name: 'Oauth2Token::AccessToken'

  has_many :refresh_tokens,
           foreign_key: 'site_id',
           class_name: 'Oauth2Token::RefreshToken'

  before_validation :set_secret,
                    on: :create

  after_create :set_manager

  scope :managed_by, lambda { |actor|
    select("DISTINCT sites.*").
      joins(actor: :sent_permissions).
      merge(Contact.received_by(actor)).
      merge(Permission.where(action: 'manage', object: nil))
  }

  %w{ url callback_url secret }.each do |m|
    define_method m do
      config[m]
    end

    define_method "#{ m }=" do |arg|
      config[m] = arg
    end
  end

  # Generate a new OAuth secret for this site client
  def refresh_secret!
    set_secret
    save!
  end

  private

  def set_secret
    self.secret = SecureRandom.hex(64)
  end

  def set_manager
    c = sent_contacts.create! receiver_id: author.id,
                              user_author: author

    c.relation_ids = [ ::Relation::Manager.instance.id ]
  end
end
