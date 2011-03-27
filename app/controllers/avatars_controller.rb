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
      #debugger
      @avatar.updating_logo = true
      #@avatar.actor_id = current_subject.actor_id
      @avatar.actor_id = Actor.normalize(current_subject).id
      if !current_subject.avatar.nil?
      	current_subject.avatar.destroy
      end
      @avatar.save     
      #redirect_to avatars_path
      redirect_to [current_subject, :profile]
    end    
  end
  
  
end
