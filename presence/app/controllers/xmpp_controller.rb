class XmppController < ApplicationController
  
  #Mapping XMPP Standar Status to Social Stream Chat Status
  STATUS = {
  '' => 'available', 
  'chat' => 'available', 
  'away' => 'away', 
  'xa' => 'away',
  'dnd' => 'dnd'
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
    
    SocialStream::Presence::XmppServerOrder::resetPresence
    
    render :text => "Ok" 
  end
  
  
  def synchronizePresence  
    unless authorization
      render :text => "Authorization error"
      return
    end 
     
    #Actual connected users
    user_slugs = params[:name]  
    
    SocialStream::Presence::XmppServerOrder::synchronizePresenceForSlugs(user_slugs)
    
    render :text => "ok"
  end
 
 
  def authorization
    return params[:password] == SocialStream::Presence.xmpp_server_password
  end
  
  
  def chatWindow
    
    if current_user and current_user.chat_enabled and (params[:userConnected]=="true")
      render :partial => 'chat/contacts'
    elsif current_user and current_user.chat_enabled
      #User not connected
      render :partial => 'chat/off'
    else
      #User with chat disabled
      render :text => ''
    end
  end
    
 
  def updateSettings
    
    success = false

    #If no section selected, skips and gives error
    if params[:settings_section].present?
      section = params[:settings_section].to_s

      #Updating User Chat settings
      if section.eql? "chat"
        if current_user and current_subject and current_subject==current_user
          current_user.chat_enabled = true if params[:enable_chat].present? and params[:enable_chat].to_s.eql? "true"
          current_user.chat_enabled = false  if !params[:enable_chat]
        end
      end

      #Here sections to add
      #if section.eql? "section_name"
      #   blah blah blah
      #end

      #Was everything ok?
      success = current_subject.save
    end

    #Flashing and redirecting
    if success
      flash[:success] = t('settings.success')
    else
      flash[:error] = t('settings.error')
    end
    redirect_to :controller => :settings, :action => :index
  end
  
  
  #Test Method
  def active_users
    @users = User.find_all_by_connected(true)
    @all_users = User.all
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