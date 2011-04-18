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

    #If we got here we are receiving XML
    doc = Nokogiri::XML(request.body.read)
    puts doc.xpath('//xmlns:title').first.content
  end
end