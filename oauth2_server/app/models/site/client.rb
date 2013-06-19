class Site::Client < Site
  validates_presence_of :url, :callback_url, :secret

  before_validation :set_secret,
                    on: :create

  after_create :set_admin

  scope :administered_by, lambda { |actor|
    joins(actor: :sent_permissions).
      merge(Contact.received_by(actor)).
      merge(Permission.where(action: 'update', object: nil))
  }

  %w{ url callback_url secret }.each do |m|
    define_method m do
      config[m]
    end

    define_method "#{ m }=" do |arg|
      config[m] = arg
    end
  end

  def to_param
    id
  end

  private

  def set_secret
    self.secret = SecureRandom.hex(64)
  end

  def set_admin
    c = sent_contacts.create! receiver_id: author.id,
                              user_author: author

    c.relation_ids = [ relation_customs.sort.first.id ]
  end
end
