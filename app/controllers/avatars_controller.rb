class AvatarsController < InheritedResources::Base

before_filter :authenticate_user!

def create
    @avatar = Avatar.create(params[:logo])
    
    
    if @avatar.new_record?
      render :new
    else
      @avatar.updating_logo = true
      @avatar.actor_id = current_subject.actor.id
      if !current_subject.avatars.nil?
      	actual_logo = current_subject.avatars.active.first
      	actual_logo.active = false
      	actual_logo.save
      end
      @avatar.active = true
      @avatar.save
      redirect_to [current_subject, :profile]
    end    
  end
  
  
end
