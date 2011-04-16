class RemoteUser < ActiveRecord::Base
  attr_accessible :name, :webfinger_slug, :hub_url, :origin_node_url
  
  validates_format_of :webfinger_slug, :with => Devise.email_regexp, :allow_blank => true
  
end