class PshbController < ApplicationController
  
  def callback
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

    atom = Proudhon::Atom.parse request.body.read

    atom.entries.each do |entry|
      Activity.from_entry entry
    end
  end
end
