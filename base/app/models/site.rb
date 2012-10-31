# Site is used to store the global configuration. Example:
# 
#   Site.config[:host] = 'example.com'
#   Site.save!
class Site < ActiveRecord::Base
  attr_accessible :config

  serialize :config, Hash

  class << self
    def current
      @current ||=
        first || create!
    end
  end
end
