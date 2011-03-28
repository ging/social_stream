class AvatarsController < InheritedResources::Base
=begin  
  def new
#    if params[:logo_logo].present?
 #    render :template => "logos/_precrop", :layout => false
  #  end
    debugger
    if params[:logo_logo]
      
    end
     respond_to do |format|
      format.html #new.html.erb
     end
 
  end
=end

def create
    @avatar = Avatar.create(params[:logo])
    
    
    if @avatar.new_record?
      render :new
    else
      @avatar.updating_logo = true
      @avatar.actor_id = Actor.normalize(current_subject).id
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
