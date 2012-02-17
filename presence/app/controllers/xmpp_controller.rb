class XmppController < ApplicationController
  
  before_filter :authorization, :only => [:setConnection, :unsetConecction, :setPresence, :unsetPresence, :resetConnection, :synchronizePresence ]
  
  #Mapping XMPP Standar Status to Social Stream Chat Status
  STATUS = {
  '' => 'available', 
  'chat' => 'available', 
  'away' => 'away', 
  'xa' => 'away',
  'dnd' => 'dnd'
  }
   
   
  ############################## 
  ########## REST API ##########
  ##############################
  
  def setConnection
    params = @dparams
    user = User.find_by_slug(params[:name])
    
    if user && !user.connected
       user.connected = true
       user.status = "available"
       user.save!
       render :text => "Ok"
       return
    end
    
    render :text => "Ok: The user was already connected"
  end
  
  
  def unsetConecction
    params = @dparams
    user = User.find_by_slug(params[:name])
    
    if user && user.connected
       user.connected = false
       user.save!
       render :text => "Ok"
       return
    end
    
    render :text => "Ok: The user was already disconnected"
  end
  
  
  def setPresence 
    params = @dparams
    user = User.find_by_slug(params[:name])
    status = params[:status]
    
    if setStatus(user,status)
      if user && !user.connected
        user.connected = true
        user.save!
      end
      render :text => "Ok: Status changed"
    else
      render :text => "Ok: Status not changed"
    end
    
  end
  
  
  def unsetPresence
    params = @dparams
    user = User.find_by_slug(params[:name])
    
    if user && user.connected
       user.connected = false
       user.save!
       render :text => "Ok"
       return
    end
    
    render :text => "Ok: The user was already disconnected"
  end
  
  
  def resetConnection
    SocialStream::Presence::XmppServerOrder::resetPresence
    render :text => "Ok" 
  end
  
  
  def synchronizePresence
    params = @dparams
    
    #Work without encrypted params
    if params[:name] == nil or params[:name].empty? or params[:name]==""
      render :text => "Ok: No users received"
      return
    end
    
    #Actual connected users
    user_slugs = params[:name].split(",")
    SocialStream::Presence::XmppServerOrder::synchronizePresenceForSlugs(user_slugs)
    render :text => "Ok"
  end
  
  
  
  #OPEN METHODS
  
  def chatWindow 
    if current_user and current_user.chat_enabled
      render :partial => 'chat/contacts'
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
    if user and status and validStatus(status) and user.status != STATUS[status]
      user.status = STATUS[status]
      user.save!
      return true
    end
    return false
  end 
  
  def validStatus(status)
    return STATUS.keys.include?(status)
  end
  
  
  #Authorization to use REST API
  def authorization
    unless SocialStream::Presence::XmppServerOrder::authorization(params)
      render :text => "Authorization error"
    end
    @dparams = SocialStream::Presence::XmppServerOrder::decryptParams(params)
  end
  
end