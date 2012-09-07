class RemoteSubjectsController < ApplicationController
  def index
    raise ActiveRecord::NotFound if params[:q].blank?

    @remote_subject =
      RemoteSubject.find_or_create_using_webfinger_id(params[:q])
      
=begin
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
=end
    
    respond_to do |format|
      format.html
    end
  end

  def show
    @remote_subject =
      RemoteSubject.find_by_slug!(params[:id])
  end
end
