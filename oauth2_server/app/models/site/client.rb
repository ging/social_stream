class Site::Client < Site
  validates_presence_of :url, :callback_url, :secret

  before_validation :set_secret,
                    on: :create

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
end
