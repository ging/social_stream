# Site is used to store the global configuration. Example:
# 
#   Site.config[:host] = 'example.com'
#   Site.save!
class Site < ActiveRecord::Base
  include SocialStream::Models::Subject

  serialize :config, Hash

  class << self
    def current
      @current ||=
        first || create!(name: "Social Stream powered site")
    end
  end
end
