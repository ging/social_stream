class XmppController < ApplicationController
  
  #Mapping XMPP Standar Status to Social Stream Chat Status
  STATUS = {
  '' => 'available', 
  'chat' => 'available', 
  'away' => 'away', 
  'xa' => 'away',
  'dnd' => 'dnd',
  #Special status to disable chat
  'disable' => 'disable'
  }
   
   
  #API METHODS
  
  def setConnection  
    unless authorization
      render :text => "Authorization error"
      return
    end
    
    user = User.find_by_slug(params[:name])
    
    if user && !user.connected
       user.connected = true
       user.status = "available"
       user.save!
       render :text => "Ok"
       return
    end
    
    render :text => "Error"
  end
  
  
  def unsetConecction
    unless authorization
      render :text => "Authorization error"
      return
    end
    
    user = User.find_by_slug(params[:name])
    
    if user && user.connected
       user.connected = false
       user.save!
       render :text => "Ok"
       return
    end
    
    render :text => "User not connected"
  end
  
  
  def setPresence  
    unless authorization
      render :text => "Authorization error"
      return
    end
    
    user = User.find_by_slug(params[:name])
    status = params[:status]
    
    if setStatus(user,status)
      if user && !user.connected
        user.connected = true
        user.save!
      end
      render :text => 'Status changed'
    else
      render :text => 'Status not changed'
    end
    
  end
  
  
  def unsetPresence  
    unless authorization
      render :text => "Authorization error"
      return
    end
    
    user = User.find_by_slug(params[:name])
    
    if user && user.connected
       user.connected = false
       user.save!
       render :text => "Ok"
       return
    end
    
    render :text => "User not connected"
  end
  
  
  def resetConnection
    unless authorization
      render :text => "Authorization error"
      return
    end
    
    SocialStream::Presence::XmppServerOrder::reset_presence
    
    render :text => "Ok" 
  end
  
  
  def synchronizePresence  
    unless authorization
      render :text => "Authorization error"
      return
    end 
     
    #Actual connected users
    user_slugs = params[:name]  
    
    SocialStream::Presence::XmppServerOrder::synchronize_presence_for_slugs(user_slugs)
    
    render :text => "ok"
  end
 
 
  def authorization
    return params[:password] == SocialStream::Presence.xmpp_server_password
  end
  
  def chatAuthWithCookie
    cookie = params[:cookie]
    render :text => "Ok"
  end
  
  def chatWindow
    if (current_user) and (current_user.status != 'disable') and (params[:userConnected]=="true")
      render :partial => 'xmpp/chat_contacts'
    else
      #User not connected or chat desactivated
      render :partial => 'xmpp/chat_off'
    end 
  end
    

 
  
  #TEST METHODS
  def active_users
    @users = User.find_all_by_connected(true)
    @all_users = User.all
  end
   
  def test
    #puts "TEST"
  end
  
  
  private
  
  def setStatus(user,status)
    if user and status and user.status != status and validStatus(status)  
      user.status = STATUS[status]
      user.save!
      return true
    end
    return false
  end 
  
  def validStatus(status)
    return STATUS.keys.include?(status)
  end
  
end