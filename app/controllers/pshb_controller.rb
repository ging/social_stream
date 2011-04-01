class PshbController < ApplicationController
  
  def callback
    #sync subscription verification
    if params['hub.mode']=='subscribe'   
      render :text => params['hub.challenge'], :status => 200
      # TO-DO: confirm that params['hub.topic'] is a real 
      # requested subscription by someone in this node
    end
    
    #sync unsubscription verification
    if params['hub.mode']=='unsubscribe'
      render :text => params['hub.challenge'], :status => 200
      # TO-DO: confirm that params['hub.topic'] is a real 
      # requested unsubscription by someone in this node
      # and delete permissions/remote actor if necessary
    end  

    logger.debug request.body.read
  end
  
  #require "net/http"
  #require "uri"
  
  #def pshb_subscription_request#(topic,hub,mode)
  #  t = Thread.new do
  #    #test
  #    hub = 'http://138.4.7.113:4567/' # last '/' is mandatory!
  #    topic = 'http://138.4.7.69:3000/api/user/demo/home.atom'
  #    mode = 'subscribe'
  #    #
  #    uri = URI.parse(hub)   
  #    response = Net::HTTP::post_form(uri,{ 'hub.callback' => pshb_callback_url, 
  #                                          'hub.mode'     => mode,
  #                                          'hub.topic'    => topic,
  #                                          'hub.verify'   => 'sync'})                                            
	#puts response.body
  #    #TO-DO: process 4XX response.status                                      
  #  end                                                                                
  #end  
end