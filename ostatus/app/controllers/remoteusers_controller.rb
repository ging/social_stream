class RemoteusersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    if params[:slug].present?
      #Selecting the remote subject
      u = RemoteSubject.find_or_create_using_wslug(params[:slug])
      
      #Creating the tie between me and the remote subject
      t = Tie.create!(:sender => current_user.actor,
                      :receiver => u.actor,
                      :relation_name => "friend") 
      
      #Requesting a subscription to the hub
      t = Thread.new do
        uri = URI.parse(SocialStream::Ostatus.hub)   
        response = Net::HTTP::post_form(uri,{ 'hub.callback' => pshb_callback_url, 
                                              'hub.mode'     => "subscribe",
                                              'hub.topic'    => u.public_feed_url,
                                              'hub.verify'   => 'sync'})
                                                                                          
      end                                                         
    end
    
    respond_to do |format|
      format.html
    end
  end
  
end
