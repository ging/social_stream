class RemoteusersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    if params[:slug].present?
      wfslug = params[:slug].split('@')
      a = RemoteUser.create!(:name => wfslug[0], 
                             :webfinger_slug => params[:slug],
                             :origin_node_url => wfslug[1],
                             :hub_url => Social2social.hub)
      home_feed = 'http://'+a.origin_node_url+'/api/user/'+a.name+'/home/'                       
      puts home_feed                       
      #TO-DO: I'M WORKING HERE
    end
    
    respond_to do |format|
      format.html
    end
  end
  
end