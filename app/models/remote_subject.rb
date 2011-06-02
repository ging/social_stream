class RemoteSubject < ActiveRecord::Base
  attr_accessible :name, :webfinger_slug, :hub_url, :origin_node_url
  
  #validates_format_of :webfinger_slug, :with => Devise.email_regexp, :allow_blank => true
  
  class << self
    def find_or_create_using_wslug(slug)
      r_user = RemoteSubject.find_by_webfinger_slug(slug)
      if r_user == nil
        wfslug = slug.split('@')
        r_user = RemoteSubject.create!(:name => wfslug[0], 
                                    :webfinger_slug => slug,
                                    :origin_node_url => wfslug[1],
                                    :hub_url => Social2social.hub)
      end
      r_user
    end
  end
  
  # Public feed url for this RemoteUser
  def public_feed_url
    "http://"+origin_node_url.to_s+"/api/user/"+name.to_s+"/public.atom"                       
  end
  
  
end
