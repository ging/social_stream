class PshbController < ApplicationController
  
  def callback
    #sync subscription verification
    if params['hub.mode']=='subscribe'   
      render :text => params['hub.challenge'], :status => 200
      # TO-DO: confirm that params['hub.topic'] is a real 
      # requested subscription by someone in this node
      return
    end
    
    #sync unsubscription verification
    if params['hub.mode']=='unsubscribe'
      render :text => params['hub.challenge'], :status => 200
      # TO-DO: confirm that params['hub.topic'] is a real 
      # requested unsubscription by someone in this node
      # and delete permissions/remote actor if necessary
      return
    end  

    #If we got here we are receiving an XML Activity Feed
    doc = Nokogiri::XML(request.body.read)
    origin = doc.xpath("//xmlns:link[@rel='self']").first['href'].split('/')
    webfinger_slug = origin[5]+"@"+origin[2]
    
    activity_texts = doc.xpath("//xmlns:content")
    activity_texts.each do |activity_text|
      r_user = RemoteSubject.find_by_webfinger_slug(webfinger_slug)
      if r_user != nil
        Post.create!(:text => activity_text.content, :_activity_tie_id => r_user.public_tie)
      end
    end
  end
end