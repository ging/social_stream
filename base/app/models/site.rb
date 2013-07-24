# Site is used to store the global configuration. Example:
# 
#   Site.config[:host] = 'example.com'
#   Site.save!
class Site < ActiveRecord::Base
  include SocialStream::Models::Subject

  serialize :config, Hash

  class << self
    def current
      ::Site::Current.instance
    end
  end
end
