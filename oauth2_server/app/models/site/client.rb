class Site::Client < Site
  validates_presence_of :url, :callback_url

  %w{ url callback_url }.each do |m|
    define_method m do
      config[m]
    end

    define_method "#{ m }=" do |arg|
      config[m] = arg
    end
  end
end
