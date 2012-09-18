class PshbController < ApplicationController
  def index
    case params['hub.mode']
    #TODO check PuSH specification about subscribe or async
    when 'subscribe', 'async'
      render :text => params['hub.challenge'], :status => 200
      # TODO: confirm that params['hub.topic'] is a real 
      # requested subscription by someone in this node
      return
    when 'unsubscribe'
      render :text => params['hub.challenge'], :status => 200
      # TODO: confirm that params['hub.topic'] is a real 
      # requested unsubscription by someone in this node
      # and delete permissions/remote actor if necessary
      return
    end  

    SocialStream::ActivityStreams.from_pshb_callback(request.body.read)
  end
end
